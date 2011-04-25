require 'rubygems'
require 'lib/estimotion_config'
require 'erb'
require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'dm-serializer'
require 'lib/model/Game'
require 'lib/model/JiraCard'
require 'lib/jira'
require 'lib/estimotion_helpers'
require 'rack-flash'
require 'sinatra/content_for'

class EstimOtion < Sinatra::Base
  include EstimotionHelpers

  use Rack::Flash
  set :root, File.dirname(__FILE__)
  set :sessions, true
  set :layout, true

  configure do 
    DataMapper.finalize
    DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/game.db")
    DataMapper.auto_upgrade!
  end

  helpers Sinatra::ContentFor

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end

  get '/' do
    erb :index, :locals => {
      :games => Game.all
    }
  end

  post '/game/join' do
    redirect "/game/#{params['game-id-select']}"
  end

  post '/game/new' do
    game = Game.new(:game_name => params['game-name'])
    errors = validate_form_input(game, params)
    issues = (errors.empty?) ? Jira.get_issues(params['game-jql']) : []

    if errors.empty? && !issues.empty? 
      game.save

      issues.each do |issue|
        jira_card_id = issue.key.gsub("-", "")
        jira_card = JiraCard.new(:jira_card_id => jira_card_id, :ticket_number => issue.key, :summary => issue.summary, :game => game)
        jira_card.save!
      end
      
      redirect "/game/#{game.id}"
    else 
      errors << "No issues returned from Jira for the given JQL" if errors.empty? && issues.empty?

      flash["game-name"] = params["game-name"]
      flash["game-jql"] = params["game-jql"]
      flash["errors"] = errors
      redirect '/'
    end
  end

  get '/game/:game_id' do
    game = Game.get(params[:game_id])
    jira_cards = JiraCard.all(:game => game, :order => [:updated_at.asc])

    erb :game, :locals => {
      :host_name => @env['SERVER_NAME'],
      :game => game,
      :json => build_json( game, jira_cards )
    }
  end

  get '/tasks' do
    game = Game.get(1)
    jira_cards = JiraCard.all(:game => game, :order => [:updated_at.asc])
    
    erb :tasks, :locals => {
      :host_name => @env['SERVER_NAME'],
      :game => game,
      :json => build_json( game, jira_cards )
    }

  end

  private

  def validate_form_input(game, params)
    errors = []

    # Datamapper validation errors
    if(!game.valid?)
      game.errors.each do |error|
        errors << error
      end
    end

    # Form specific errors
    if(params['game-jql'] == nil || params['game-jql'].strip.size == 0)
      errors << "JQL query must not be blank"
    end

    return errors
  end

  run!
end
