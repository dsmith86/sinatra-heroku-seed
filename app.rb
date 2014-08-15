require 'sinatra'
require 'net/http'
require 'net/https'
require 'base64'
require 'json'
require './config/environments'

get '/' do
	'Hello, World!'
end