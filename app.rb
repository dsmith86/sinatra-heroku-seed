require 'bundler'
Bundler.require
require 'net/http'
require 'net/https'
require 'base64'
require 'json'
require './config/environments'

class Application < Sinatra::Base
	enable :sessions
	register Sinatra::Flash

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
			params['user']['username'] && params['user']['password']
		end

		def authenticate!
			user = User.first(username: params['user']['username'])

			if user.nil?
				fail!("The username you entered does not exist.")
			elseif user.authenticate(params['user']['password'])
				success!(user)
			else
				fail!("Could not log in")
			end
		end
	end

	get '/' do
		'Hello World!'
	end
end