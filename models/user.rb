require 'data_mapper'
require 'dm-postgres-adapter'
require 'bcrypt'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

class User
	include DataMapper::Resource
	include BCrypt

	property :id, Serial, :key => true
	property :username, String, :length => 3..50
	property :password, BCryptHash

	def authenticate(attempted_password)
		if self.password == attempted_password
			true
		else
			false
		end
	end
end

DataMapper.finalize
DataMapper.auto_upgrade!