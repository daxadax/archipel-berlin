require 'sinatra'
require 'sinatra/namespace'
require './lib/services/slack_bot.rb'

class ArchipelBerlinApp < Sinatra::Application
  enable :sessions

  # catch exceptions and send them to slack
  error Exception do
    e = env['sinatra.error']

    Services::SlackBot.notify_error(
      message: "#{e.exception.class}: #{e.message}",
      backtrace: e.backtrace.join("\n")
    )

    style = '%h1{style: "text-align:center;padding-top:2em;"}'
    haml "#{style} Sorry, something went wrong!"
  end

  namespace '/admin' do
    before do
      logger.info "Authenticating request"
      authenticate!
      set_current_user!
    end

    get '/' do
      redirect 'admin/dashboard'
    end

    get '/dashboard' do
      @todays_date = Date.today
      @shopify_orders = ArchipelBerlin::Models::ShopifyOrder.reverse(:date).all
      @delivery_requests = Apocalypse::Models::DeliveryRequest.reverse(:created_at).all
      display_admin_page 'dashboard'
    end

    post '/upload_orders' do
      tempfile = params['orders_data']['tempfile']
      csv_string = File.read(tempfile)
      date = params['filedate']

      order = ArchipelBerlin::Models::ShopifyOrder.update_or_create(
        { date: date }, # query attribute to find or create by
        {
          csv_string: csv_string,
          uploaded_by: @current_user
        } # attributes to set
      )

      # generate reports after create
      order.generate_reports

      # messages << "Data is being uploaded..."
      redirect 'admin/dashboard'
    end

    post '/generate_reports' do
      date = params['date']
      # TODO: why am i not calling the command directly, wtf?
      ArchipelBerlin::Models::ShopifyOrder.find(date: date).generate_reports
    end

    get '/download_orders/:date' do
      date = params['date']
      csv_string = ArchipelBerlin::Models::ShopifyOrder.find(date: date).csv_string

      file = Tempfile.new("#{date}.csv")
      file.write(csv_string)
      file.rewind

      send_file file, filename: "#{date}.csv", type: 'text/csv', disposition: 'attachment'

      file.close
      file.unlink
    end

    get '/download_reports/:date' do
      date = params['date']
      shopify_order = ArchipelBerlin::Models::ShopifyOrder.find(date: date)
      archive = shopify_order.generated_reports

      file = Tempfile.new("#{shopify_order.report_date}.zip")
      file.write(archive)
      file.rewind

      send_file_options = {
        filename: "#{shopify_order.report_date}.zip",
        type: 'application/zip',
        disposition: 'attachment'
      }
      send_file(file, send_file_options)

      file.close
      file.unlink
    end

    get '/login' do
      display_admin_page 'login', hide_header: true
    end

    get '/logout' do
      session['current_user'] = nil
      redirect 'admin/login'
    end

    post '/login' do
      logger.info "Processing login for user #{params['username']}"

      user_key = ENV[params['username'].upcase]
      auth_key = params['password']

      if user_key == auth_key
        session['current_user'] = params['username']
        redirect 'admin/dashboard'
      else
        messages << 'Login failed. Please contact administrator if you need help.'
        redirect 'admin/login'
      end
    end
  end

  get '/' do
    redirect 'apocalypse/request_pickup'
  end

  get '/apocalypse/request_pickup' do
    display_page 'apocalypse/form'
  end

  post '/apocalypse/request_pickup' do
    # TODO: simplify this equality check or hide it somewhere
    if params['pickup_location']['address'] == params['invoice_location']['address'] &&
      params['pickup_location']['zip'] == params['invoice_location']['zip'] &&
      params['pickup_location']['contact'] == params['invoice_location']['contact']

      pickup_location = invoice_location = Apocalypse::Models::Location.find_or_create(
        params['pickup_location'].merge(email: params['invoice_location']['email'])
      )
    else
      pickup_location = Apocalypse::Models::Location.
        find_or_create(params['pickup_location'])

      invoice_location = Apocalypse::Models::Location.
        find_or_create(params['invoice_location'])
    end

    delivery_request = Apocalypse::Models::DeliveryRequest.create(
      pickup_location_id: pickup_location.id,
      invoice_location_id: invoice_location.id,
    )

    params['deliveries'].each do |index, data|
      location = Apocalypse::Models::Location.find_or_create(data['delivery_location'])

      delivery = Apocalypse::Models::Delivery.create(
        available_from: DateTime.parse(data['available_from']),
        notes: data['notes'],
        delivery_request_id: delivery_request.id,
        location_id: location.id
      )

      data['items'].each do |index, item|
        Apocalypse::Models::DeliveryItem.create(item.merge(delivery_id: delivery.id))
      end
    end

    pdf_path = Apocalypse::Adapters::DeliveryPdf.call(delivery_request.id)

    Services::SlackBot.notify_delivery_request(
      pickup_location: pickup_location.name,
      pdf_path: pdf_path
    )

    status 201
    url('apocalypse/confirmation')
  rescue => e
    Services::SlackBot.notify_error(
      message: "#{e.exception.class}: #{e.message}",
      backtrace: e.backtrace.join("\n")
    )

    status 500
  end

  get '/apocalypse/confirmation' do
    display_page 'apocalypse/confirmation'
  end

  private

  def authenticate!
    return if current_user?
    return if request.path_info == '/admin/login'
    redirect 'admin/login'
  end

  def current_user?
    !!session['current_user']
  end

  def set_current_user!
    @current_user = session['current_user']
  end

  def messages
    session['messages'] ||= Array.new
  end

  def display_messages_and_reset_cache(&block)
    messages.each &block
    messages.clear
  end

  def display_page(location, locals = {})
    @hide_header = locals.delete(:hide_header)

    options = {
      layout_options: { views: 'views/layouts' },
      layout: locals.fetch(:layout) { :default },
      locals: locals
    }

    haml location.to_sym, options
  end

  def display_admin_page(location, locals = {})
    display_page("admin/#{location}", locals.merge(layout: :admin))
  end

  def display_partial(location, locals = {})
    @hide_header = locals.delete(:hide_header)
    haml location.to_sym, layout: false, locals: locals
  end
end
