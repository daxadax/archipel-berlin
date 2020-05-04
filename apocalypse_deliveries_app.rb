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
    display_page 'dashboard'
  end

  get '/login' do
    display_page 'login'
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
