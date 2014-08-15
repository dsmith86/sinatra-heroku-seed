require 'bundler'
Bundler.require
require 'net/http'
require 'net/https'
require 'base64'
require 'json'
require './config/environments'
require './models/user'

class Application < Sinatra::Base
	enable :sessions
	register Sinatra::Flash
	register SinatraMore::RoutingPlugin

	map :auth do |namespace|
		namespace.map(:index).to("/")
		namespace.map(:login).to("/auth/login")
		namespace.map(:logout).to("/auth/logout")
		namespace.map(:unauthenticated).to("/auth/unauthenticated")
		namespace.map(:protected).to("/protected")
	end

	use Warden::Manager do |config|
		config.serialize_into_session {|user| user.id}

		config.serialize_from_session {|id| User.get(id)}

		config.scope_defaults :default, strategies: [:password], action: 'auth/unauthenticated'
		config.failure_app = self
	end

	Warden::Manager.before_failure do |env, opts|
		env['REQUEST_METHOD'] = 'POST'
	end

	Warden::Strategies.add(:password) do
		def valid?
			return false if params.empty?

			params['user']['username'] && params['user']['password']
		end

		def authenticate!
			user = User.first(username: params['user']['username'])

			if user.nil?
        fail!("The username you entered does not exist.")
      elsif user.authenticate(params['user']['password'])
        success!(user)
      else
        fail!("Could not log in")
      end
		end
	end

	namespace :auth do
		get :index do
			erb :index
		end

		get :login do
			erb :login
		end

		post :login do
			env['warden'].authenticate!

			flash[:success] = env['warden'].message

			if session[:return_to].nil?
				redirect '/'
			else
				redirect session[:return_to]
			end
		end

		get :logout do
			env['warden'].raw_session.inspect
			env['warden'].logout
			flash[:success] = 'Successfully logged out'
			redirect '/'
		end

		post :unauthenticated do
			session[:return_to] = env['warden.options'][:attempted_path]	
			puts env['warden.options'][:attempted_path]
			flash[:error] = env['warden'].message || "You must log in"
			redirect '/auth/login'
		end

		get :protected do
			env['warden'].authenticate!
			@current_user = env['warden'].user
			erb :protected
		end
	end

end