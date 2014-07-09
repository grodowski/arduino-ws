require 'goliath'
require 'goliath/websocket'
require 'grape'
require 'redis'
require 'json'
require './api/echo'

class WsServer < Goliath::WebSocket

  def on_open(env)
    puts 'received on_open'
  end

  def on_message(env, msg)
    puts 'received on_message with ' + msg

    env['handler'].send_text_frame msg

  end

  def on_close(env)
    env.logger.info("CLOSED")
  end

  def on_error(env, error)
    puts error
  end

  # def response(env)
  #
  #   API::Echo.call(env)
  #
  #   # redis = Redis.new
  #   # redis.publish 'test-channel', {message: 'hello, world!'}.to_json
  #   # [200, {}, 'Success']
  # end

end