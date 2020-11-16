require 'sinatra'
require 'sinatra/namespace'
require './lib/services/slack_bot.rb'

class BaseController < Sinatra::Application
  enable :sessions

  # catch exceptions and send them to slack
  error Exception do
    e = env['sinatra.error']

    Services::SlackBot.notify_error(
      message: "#{e.exception.class}: #{e.message}",
      backtrace: e.backtrace.join("\n")
    )

    style = '%h1{style: "text-align:center;padding-top:2em;"}'
    haml "#{style} Sorry, something went wrong!"
  end

  get '/' do
    redirect '/apocalypse/request_pickup'
  end

  private

  def authenticate!
    return if current_user?
    return if request.path_info == '/admin/login'
    redirect 'admin/login'
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
    def logged_in?
      #check if current_user variable is set
      #!! converts value to boolean
      # use session to determine the definition of being logged in
      !!current_user
    end

    def current_user
      Apocalypse::Models::User[session[:user_id]]
    end
  end
end
