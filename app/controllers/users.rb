class UsersController < BaseController
  get '/signup' do
    redirect "/users/#{current_user.id}" if logged_in?
    display_page 'apocalypse/signup'
  end

  post '/signup' do
    # Won't be saved to db unless user filled out password
    if params['email'].empty? || params['password'].empty?
      messages = "Please enter an email and password!"
      redirect '/signup'
    end

    user = Apocalypse::Models::User.new(
      email: params['email'],
      password_digest: BCrypt::Password.create(params['password'])
    )

    # TODO: test the notifications
    # Check if this user has already been registered
    if Apocalypse::Models::User.find(email: user.email)
      messages = "A user with this email already exists."
      redirect '/signup'

    # save user and redirect to next page
    else
      user.save
      session[:user_id] = user.id

      if params[:signup_type] == 'create'
        # i want to register a new organization
        redirect 'organizations/new'
      else
        # i want to join an existing organization
        redirect 'organizations/how_to_join'
      end
    end
  end

  # users show page
  # get '/users/:id' do
  # end
end
