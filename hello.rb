require 'goliath'
require 'redis'
require 'json'

class Hello < Goliath::API
	def response(env)
    redis = Redis.new
    redis.publish 'test-channel', {message: 'hello, world!'}.to_json
		[200, {}, 'Success']
	end
end
