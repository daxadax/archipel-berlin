class DeliveryRequestsController < BaseController
  get '/apocalypse/request_pickup' do
    # DEV CHEAT
    # session[:user_id] = Apocalypse::Models::User.all.last.id

    organization = current_user&.organization
    delivery_locations = Apocalypse::Models::Location.
      where(id: organization&.locations&.map(&:id)).invert

    display_page 'apocalypse/form',
      organization: organization,
      delivery_locations: delivery_locations
  end

  post '/apocalypse/request_pickup' do
    # more A / B stuff before switch
    if current_user
      pickup_location_id = params.dig('pickup_location_select', 'pickup_location_id')&.to_i
      pickup_contact_id = params.dig('pickup_contact_select', 'pickup_contact_id')&.to_i
      invoice_location_id = current_user.organization.id
    else
      if params['pickup_location']['address'] == params['invoice_location']['address'] &&
        params['pickup_location']['zip'] == params['invoice_location']['zip'] &&
        params['pickup_location']['contact'] == params['invoice_location']['contact'].merge(email: params['invoice_location']['email'])

        pickup_location = invoice_location = Apocalypse::Models::Location.
          find_or_create(params['pickup_location'])

        pickup_contact = Apocalypse::Models::Contact.
          find_or_create(params['pickup_location']['contact'])

        pickup_location_id = pickup_location.id
        pickup_contact_id = pickup_contact.id
        invoice_location_id = invoice_location.id
      else
        pickup_location = Apocalypse::Models::Location.
          find_or_create(params['pickup_location'])

        pickup_contact = Apocalypse::Models::Contact.
          find_or_create(params['pickup_location']['contact'])

        invoice_location = Apocalypse::Models::Location.
          find_or_create(params['invoice_location'])
      end
    end

    delivery_request = Apocalypse::Models::DeliveryRequest.create(
      pickup_location_id: pickup_location_id,
      pickup_contact_id: pickup_contact_id,
      invoice_location_id: invoice_location_id,
      organization_id: current_user&.organization&.id,
      created_by_id: current_user.id
    )

    params['deliveries'].each do |index, data|
      # new flow
      if current_user
        location_id = data.dig('delivery_location_select', 'delivery_location_id').to_i
        contact_id = data.dig('delivery_contact_select', 'delivery_contact_id').to_i

        # zero is the key used to designate adding a new location
        if location_id.zero?
          # create new delivery location
          location = Apocalypse::Models::Location.find_or_create(
            name: data['delivery_location_input']['name'],
            address: data['delivery_location_input']['address'],
            zip: data['delivery_location_input']['zip'],
            city: data['delivery_location_input']['city'],
            # NOTE: delivery location should not belong to org.
            # it should just be in common pool. i think that's ok?
            # organization_id: current_user.organization_id
          )

          location_id = location.id
        end

        # zero is the key used to designate adding a new contact
        if contact_id.zero?
          # find or create new contact
          contact = Apocalypse::Models::Contact.find_or_create(
            name: data['delivery_contact_input']['name'],
            phone: data['delivery_contact_input']['phone'],
            location_id: location_id
          )

          contact_id = contact_id
        end

      # old flow
      else
        location_id = Apocalypse::Models::Location.find_or_create(data['delivery_location']).id
        contact_id = Apocalypse::Models::Location.
          find_or_create(data['delivery_location']['contact']).id
      end


      delivery = Apocalypse::Models::Delivery.create(
        available_from: DateTime.parse(data['available_from']),
        notes: data['notes'],
        delivery_request_id: delivery_request.id,
        location_id: location_id,
        contact_id: contact_id
      )

      data['items'].each do |index, item|
        Apocalypse::Models::DeliveryItem.create(item.merge(delivery_id: delivery.id))
      end
    end

    # generate pdf
    pdf_path = Apocalypse::Adapters::DeliveryPdf.call(delivery_request.id)
    pickup_location = current_user.organization if current_user

    # TODO: this will need to be updated later as well
    Services::SlackBot.notify_delivery_request(
      pickup_location: pickup_location.name,
      pdf_path: pdf_path
    )

    status 201
    url('apocalypse/confirmation')
  rescue => e
    Services::SlackBot.notify_error(
      message: "#{e.exception.class}: #{e.message}",
      backtrace: e.backtrace.join("\n"),
      error: e
    )

    status 500
    "We're sorry, something went wrong!"
  end

  get '/apocalypse/confirmation' do
    display_page 'apocalypse/confirmation'
  end
end
