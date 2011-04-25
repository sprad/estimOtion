require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-serializer'

class JiraCard 
  include DataMapper::Resource
	property :id, Serial
	property :jira_card_id, String
	property :ticket_number, String
	property :summary, String
	property :location, String, :default  => "card-pile"
	property :updated_at, Time

  belongs_to :game
end
