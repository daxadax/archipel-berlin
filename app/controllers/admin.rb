class AdminController < BaseController
  namespace '/admin' do
    before do
      authenticate_admin!
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

    patch '/delivery_requests/status' do
      delivery_request = Apocalypse::Models::DeliveryRequest[params['id'].to_i]
      return status 404 unless delivery_request

      # TODO: make delivery request states as more robust solution
      case params['status']
      when 'confirm'
        delivery_request.update(acknowledged_at: Time.now)
      end

      status 200
      { message: 'status has been updated' }
    end
  end

  private

  def authenticate_admin!
    redirect '/login' unless current_user.super_user?
    authenticate!
  end
end
