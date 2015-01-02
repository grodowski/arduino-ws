config['db'] = EM::Synchrony::ConnectionPool.new(size: 5) do 
   mongo = EM::Mongo::Connection.new(ENV['DB_HOST'], 27017, 1, {reconnect_in: 1})
   mongo.db ENV['DB_NAME']
end

config['redis'] = EM::Synchrony::ConnectionPool.new(size: 5) do 
  EM::Hiredis.connect
end
