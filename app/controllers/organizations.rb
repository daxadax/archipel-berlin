class OrganizationsController < BaseController
  get '/organizations/new' do
    # redirect "/users/#{current_user.id}" if logged_in?
    # display_page 'apocalypse/organizations/new'
  end

  post '/organizations/new' do
  end

  get '/organizations/how_to_join' do
    display_page 'apocalypse/organizations/how_to_join'
  end
end
