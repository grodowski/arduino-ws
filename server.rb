require 'goliath'
require 'grape'
require 'redis'
require 'json'
require './api/echo'

class Server < Goliath::API
	
  def response(env)

    API::Echo.call(env)

    # redis = Redis.new
    # redis.publish 'test-channel', {message: 'hello, world!'}.to_json
		# [200, {}, 'Success']
	end
    
end
