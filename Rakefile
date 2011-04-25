namespace :websocket do
  task :start do
    puts "Starting Websocket Server..."
    `ruby websocket_server.rb`
  end
end

namespace :sinatra do
  task :start do
    puts "Starting Sinatra Web Server"
    `ruby server.rb`
  end
end

multitask :start => ['websocket:start', 'sinatra:start']
