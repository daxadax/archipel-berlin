class OrganizationsController < BaseController
  get '/organizations/new' do
    # redirect if user already has an organization?
    display_page 'apocalypse/organizations/new'
  end

  post '/organizations/new' do
    organization = Apocalypse::Models::Organization.create(
      name: params['org_name'],
      address: params['org_address'],
      zip: params['org_zip'],
      city: params['org_city']
    )

    # attach organization to current user
    current_user.update(organization_id: organization.id)

    location = Apocalypse::Models::Location.create(
      organization_id: organization.id,
      name: params['location_name'],
      address: params['location_address'],
      zip: params['location_zip'],
      city: params['location_city']
    )

    contact = Apocalypse::Models::Contact.create(
      location_id: location.id,
      name: params['contact_name'],
      email: params['contact_email'],
      phone: params['contact_phone']
    )

    # TODO: rescue error and send to slack

    status 201
    redirect "/organizations/dashboard"
  end

  get '/organizations/how_to_join' do
    display_page 'apocalypse/organizations/how_to_join'
  end

  get '/organizations/dashboard' do
    organization = Apocalypse::Models::Organization[current_user.organization_id]

    if organization.nil?
      # 404 page
    else
      display_page 'apocalypse/organizations/dashboard', organization: organization
    end
  end
end
