require 'sinatra'
require 'sinatra/namespace'

class ArchipelBerlinApp < Sinatra::Application
  enable :sessions

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
      @delivery_requests = Apocalypse::Models::DeliveryRequest.all
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
    display_page 'apocalypse/form', pickup_zipcodes: Apocalypse::PICKUP_ZIPCODES
  end

  post '/apocalypse/request_pickup' do
    attributes = parse_pickup_request(params)

    Apocalypse::Models::DeliveryRequest.create(
      pickup_contact_name: attributes['pickup']['contact'],
      pickup_contact_phone: attributes['pickup']['phone'],
      pickup_business_name: attributes['pickup']['business'],
      pickup_address: attributes['pickup']['address'],
      pickup_city: attributes['pickup']['city'],
      pickup_zip: attributes['pickup']['zip'],
      invoice_contact_name: attributes['invoice']['contact'],
      invoice_contact_email: attributes['invoice']['email'],
      invoice_business_name: attributes['invoice']['business'],
      invoice_address: attributes['invoice']['address'],
      invoice_city: attributes['invoice']['city'],
      invoice_zip: attributes['invoice']['zip'],
      total_weight_in_kg: attributes['total_weight_in_kg'],
      delivery_locations_json: attributes['delivery_locations'].to_json
    )

    status 201
    url('apocalypse/confirmation')
  end

  get '/apocalypse/confirmation' do
    display_page 'apocalypse/confirmation'
  end

  private

  def parse_pickup_request(params)
    result = {}

    result['total_weight_in_kg'] = params.delete('total_weight_in_kg')

    params.each do |k,v|
      split_key = k.split('_')

      # create sub-hash if it doesn't exist
      result[split_key.first] =  {} if result[split_key.first].nil?

      # populate sub-hash
      result[split_key.first][split_key.drop(1).join('_')] = v
    end

    dropoffs = result.delete('dropoff')

    grouped_dropoffs = dropoffs.group_by { |k,v| k.split('_').last }
    result['delivery_locations'] = []

    grouped_dropoffs.each do |dropoff_index, data|
      dropoff = {}

      # push a single, cleaned-up delivery location into the collection
      result['delivery_locations'] << data.each { |k,v| dropoff[k.split('_').first] = v }
    end

    result
  end

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
