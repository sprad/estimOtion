require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-serializer'

class Player 
  include DataMapper::Resource
	property :id, Serial
	property :player_name, String
	property :photo_url, String
end
