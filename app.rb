require 'sinatra'
require 'net/http'
require 'net/https'
require 'base64'
require 'json'
require 'pg'
require 'sinatra/activerecord'
require './config/environments'

get '/' do
	'Hello, World!'
end