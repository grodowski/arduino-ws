require 'goliath'
require 'goliath/websocket'
require 'json'
require 'em-mongo'
require 'em-hiredis'

# usage 
# ruby client_socet_server.rb -sv -p 9001

class ClientSocketServer < Goliath::WebSocket 
  attr_accessor :redis
  
  def on_open(env)
    @redis = EM::Hiredis.connect
    
    # find all sensors to subscribe to from mongo
    # for now hardcoded
    
    pubsub = redis.pubsub
    pubsub.psubscribe('ard_t*').callback do 
      env.logger.info 'Subscribed'
    end
    pubsub.on(:pmessage) do |key, chan, msg|
      env.logger.info msg
      env['handler'].send_text_frame msg
    end
  end
  
  def on_message(env)
    
  end
  
  def on_close(env)
    env.logger.info('Socket connection closed')
  end

  def on_error(env, error)
    env.logger.error error
  end
  
end