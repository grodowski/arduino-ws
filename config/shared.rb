require 'em-mongo'
require 'em-hiredis'

config['db'] = EM::Synchrony::ConnectionPool.new(size: 5) do 
   mongo = EM::Mongo::Connection.new(ENV['DB_HOST'])
   mongo.db ENV['DB_NAME']
   puts "Connected to #{ENV['DB_NAME']} on #{ENV['DB_HOST']}"
end

config['redis'] = EM::Synchrony::ConnectionPool.new(size: 5) do 
  EM::Hiredis.connect
  puts "Redis Connected..."
end