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
    organization = current_user.organization

    if organization.nil?
      # 404 page
    else
      display_page 'apocalypse/organizations/dashboard',
        organization: organization,
        layout: :organization_dashboard
    end
  end

  get '/organizations/requests' do
    organization = current_user.organization

    if organization.nil?
      # 404 page
    else
      display_page 'apocalypse/organizations/requests',
        organization: organization,
        layout: :organization_dashboard
    end
  end

  get '/organizations/locations' do
    organization = current_user.organization

    if organization.nil?
      # 404 page
    else
      display_page 'apocalypse/organizations/locations',
        organization: organization,
        layout: :organization_dashboard
    end
  end

  get '/organizations/users' do
    organization = current_user.organization

    if organization.nil?
      # 404 page
    else
      display_page 'apocalypse/organizations/users',
        organization: organization,
        layout: :organization_dashboard
    end
  end

  get '/organizations/invoices' do
    organization = current_user.organization

    if organization.nil?
      # 404 page
    else
      display_page 'apocalypse/organizations/invoices',
        organization: organization,
        layout: :organization_dashboard
    end
  end
end
