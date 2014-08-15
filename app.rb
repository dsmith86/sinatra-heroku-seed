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

	get '/' do
		'Hello World!'
	end
end