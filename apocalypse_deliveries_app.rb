class ApocalypseDeliveriesApp < Sinatra::Application
  enable :sessions

  before do
    logger.info "Authenticating request"
    authenticate!
    set_current_user!
  end

  get '/' do
    redirect 'dashboard'
  end

  get '/dashboard' do
    @todays_date = Date.today
    @shopify_orders = ApocalypseAdmin::Models::ShopifyOrder.reverse(:date).all
    display_page 'dashboard'
  end

  post '/upload_orders' do
    tempfile = params['orders_data']['tempfile']
    csv_string = File.read(tempfile)
    date = params['filedate']

    order = ApocalypseAdmin::Models::ShopifyOrder.update_or_create(
      { date: date }, # query attribute to find or create by
      {
        csv_string: csv_string,
        uploaded_by: @current_user
      } # attributes to set
    )

    # generate reports after create
    order.generate_reports

    # messages << "Data is being uploaded..."
    redirect 'dashboard'
  end

  post '/generate_reports' do
    date = params['date']
    ApocalypseAdmin::Models::ShopifyOrder.find(date: date).generate_reports
  end

  get '/download_orders/:date' do
    date = params['date']
    csv_string = ApocalypseAdmin::Models::ShopifyOrder.find(date: date).csv_string

    file = Tempfile.new("#{date}.csv")
    file.write(csv_string)
    file.rewind

    send_file file, filename: "#{date}.csv", type: 'text/csv', disposition: 'attachment'

    file.close
    file.unlink
  end

  get '/download_reports/:date' do
    date = params['date']
    shopify_order = ApocalypseAdmin::Models::ShopifyOrder.find(date: date)
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
    display_page 'login', hide_header: true
  end

  get '/logout' do
    session['current_user'] = nil
    redirect 'login'
  end

  post '/login' do
    logger.info "Processing login for user #{params['username']}"

    user_key = ENV[params['username'].upcase]
    auth_key = params['password']

    if user_key == auth_key
      session['current_user'] = params['username']
      redirect 'dashboard'
    else
      messages << 'Login failed. Please contact administrator if you need help.'
      redirect 'login'
    end
  end

  private

  def authenticate!
    return if current_user?
    return if request.path_info == '/login'
    redirect 'login'
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

  def display_partial(location, locals = {})
    @hide_header = locals.delete(:hide_header)
    haml location.to_sym, layout: false, locals: locals
  end
end
