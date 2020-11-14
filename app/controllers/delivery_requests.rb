class DeliveryRequestsController < BaseController
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
end
