require 'redis'
require 'json' 

redis = Redis.new

puts 'Subscribing...'

redis.subscribe 'test-channel' do |on|
  on.message do |channel, msg|
    data = JSON.parse msg
    puts "Received message: #{data['message']}"
  end
end