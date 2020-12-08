class UsersController < BaseController
  get '/login' do
    display_page 'apocalypse/login'
  end

  post '/login' do
    user = Apocalypse::Models::User.find(email: params[:email])

    if user && BCrypt::Password.new(user.password_digest) == params['password']
      session['user_id'] = user.external_id
      set_current_user!
      if user.super_user?
        redirect '/admin/dashboard'
      else
        redirect '/organizations/dashboard'
      end
    else
      notification[:type] = 'warning'
      notification[:message] = 'That user doesn\'t exist in our system'
      display_page 'apocalypse/login'
    end
  end

  get '/logout' do
    session.clear
    redirect '/login'
  end

  get '/signup' do
    redirect "/organizations/dashboard" if logged_in?
    display_page 'apocalypse/signup'
  end

  post '/signup' do
    # Won't be saved to db unless user filled out password
    if params['email'].empty? || params['password'].empty?
      notification[:type] = 'warning'
      notification[:message] = 'Please enter an email and password'
      redirect '/signup'
    end

    user = Apocalypse::Models::User.new(
      email: params['email'],
      nickname: params['email'].split('@').first,
      external_id: SecureRandom.uuid,
      password_digest: BCrypt::Password.create(params['password']),
      administrator: params[:signup_type] == 'create' ? true : false
    )

    # Check if this user has already been registered
    if Apocalypse::Models::User.find(email: user.email)
      notification[:type] = 'warning'
      notification[:message] = 'A user with this email already exists'
      redirect '/signup'

    # save user and redirect to next page
    else
      user.save
      session['user_id'] = user.external_id
      set_current_user!

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
