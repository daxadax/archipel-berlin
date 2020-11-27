require 'sinatra'
require 'sinatra/namespace'

if ENV["RACK_ENV"] == 'production'
  require './lib/services/slack_bot.rb'
else
  require './spec/mocks/slack_bot.rb'
end

class BaseController < Sinatra::Application
  enable :sessions

  # catch exceptions and send them to slack
  error Exception do
    e = env['sinatra.error']

    Services::SlackBot.notify_error(
      message: "#{e.exception.class}: #{e.message}",
      backtrace: e.backtrace.join("\n"),
      error: e
    )

    style = '%h1{style: "text-align:center;padding-top:2em;"}'
    haml "#{style} Sorry, something went wrong!"
  end

  before do
    authenticate!
  end

  get '/' do
    redirect '/apocalypse/request_pickup'
  end

  get '/utils/contact_options_for_location' do
    location = Apocalypse::Models::Location[params[:location_id].to_i]

    location.contacts.map { |c| { id: c.id, name: c.name } }.to_json
  end

  private

  attr_reader :current_user

  def authenticate!
    return if request.path_info =~ /stylesheets/

    set_current_user! && return if logged_in?

    # TODO: this unless will go after users flow fully implemented
    return if request.path_info == '/apocalypse/request_pickup'

    return if request.path_info == '/login'
    return if request.path_info == '/admin/login'
    return if request.path_info == '/signup'

    redirect '/login'
  end

  def logged_in?
    !!session['user_id']
  end

  def set_current_user!
    @current_user = Apocalypse::Models::User.find(external_id: session['user_id'])
  end

  def notification
    session['notification'] ||= Hash.new
  end

  def clear_notification
    notification.clear
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

  def display_admin_page(location, locals = {})
    display_page("admin/#{location}", locals.merge(layout: :admin))
  end

  def display_partial(location, locals = {})
    @hide_header = locals.delete(:hide_header)
    haml location.to_sym, layout: false, locals: locals
  end

  helpers do
    def delivery_status_class(status)
      case status
      when 'confirmed' then 'success'
      when 'rejected' then 'danger'
      when 'pending' then 'warning'
      end
    end
  end
end
