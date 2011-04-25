require 'rubygems'
require 'em-websocket'
require 'eventmachine'
require 'json'
require 'dm-core'
require 'dm-serializer'
require 'lib/model/Game'
require 'lib/model/JiraCard'
require 'lib/estimotion_helpers'

host = '0.0.0.0'
port = 9394

module FlashPolicyServer  
  def receive_data(data)
    send_data(respond_with_policy(data))
  end
  
    def respond_with_policy(request)
      policy = %Q{<?xml version="1.0"?>
  <!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
  <cross-domain-policy>
    <allow-access-from domain="opower.com" to-ports="9394" />
  </cross-domain-policy>
      }
    end
end

EventMachine.run do
  include EstimotionHelpers
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/game.db")
  @estimation_party = EM::Channel.new

  EventMachine::WebSocket.start(:host => host, :port => port, :debug => true) do |ws|
    # fires when we open a connection
    ws.onopen do
      puts "connection open"
      
      # Register the estimation party listener
      sid = @estimation_party.subscribe do |msg|
        puts "Sending data to the front end"
        ws.send msg 
      end
      
      # fires when we receive a message on the channel
      ws.onmessage do |msg|
        puts "on message called"
        parsed_message = JSON.parse(msg)

        game = Game.get("#{parsed_message['game']}")

        jira_card = JiraCard.first(:jira_card_id => "#{parsed_message['id']}", :game => game)

        jira_card.update!(:location => "#{parsed_message['location']}", :updated_at => Time.now)

        cards = JiraCard.all(:game => game, :order => [:updated_at.asc])

        @estimation_party.push "#{build_json(game, cards)}"
      end
      
      # fires when someone leaves
      ws.onclose do
        @estimation_party.unsubscribe(sid)
        @estimation_party.push "Estimation Party is over for #{sid}."
      end
    end
  end
  puts "Estimation party server started"
end

EventMachine::start_server host, port, FlashPolicyServer
