require 'goliath'
require 'goliath/websocket'
require 'json'
require 'hashie'

if Goliath.env?(:development)
  require 'dotenv'
  Dotenv.load
end

# dev:
# ruby client_socet_server.rb -sv -p 9001
# production:
# ruby client_socket_server.rb -l dashboard/log/client_socket.log -p 9001 -d -e production

class ClientSocketServer < Goliath::WebSocket
  def on_open(env)    
    env[:channels] = []
    env[:pubsub] = redis.pubsub
    env[:user_oid] = BSON::ObjectId(env['REQUEST_URI'].gsub('/', ''))

    sensors = db.collection(:sensors).find(user_id: env[:user_oid]).defer_as_a
    sensors.callback do |arr|
      env[:pubsub].on(:message) do |channel, msg|
        env.logger.info "#{channel}: #{msg}"
        env['handler'].send_text_frame msg
      end
      arr.each do |sensor|
        next unless sensor
        c_name = sensor['device_uid']
        env[:pubsub].subscribe(c_name).callback do
          env[:channels] << (c_name)
          env.logger.info "subscribed to #{c_name}"
        end
      end
    end

  end

  def on_message(env, msg)
    body = Hashie::Mash.new(JSON.parse msg)
    if body.type == 'subscr'
      c = body.device_uid
      env[:pubsub].subscribe(c).callback do 
        env[:channels] << c
        env.logger.info "subscribed to #{c}"
      end 
    end
  end

  def on_close(env)
    env[:channels].each { |c| env[:pubsub].unsubscribe(c) }
    env.logger.info("socket connection closed for #{env[:user_oid]}")
  end

  def on_error(env, error)
    env.logger.error error
  end

end