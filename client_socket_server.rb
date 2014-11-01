require 'goliath'
require 'goliath/websocket'
require 'json'
require 'em-mongo'
require 'em-hiredis'
require 'hashie'

# usage 
# ruby client_socet_server.rb -sv -p 9001

class ClientSocketServer < Goliath::WebSocket
  def on_open(env)
    env[:mongo] = EM::Mongo::Connection.new('localhost')
    env[:db] = env[:mongo].db('dashboard_development')
    env[:redis] = EM::Hiredis.connect
    env[:channels] = []

    pubsub = env[:redis].pubsub
    env[:user_oid] = BSON::ObjectId(env['REQUEST_URI'].gsub('/', ''))

    sensors = env[:db].collection(:sensors).find(user_id: env[:user_oid]).defer_as_a
    sensors.callback do |arr|
      pubsub.on(:message) do |channel, msg|
        env.logger.info "#{channel}: #{msg}"
        env['handler'].send_text_frame msg
      end
      arr.each do |sensor|
        next unless sensor
        c_name = sensor['device_uid']
        pubsub.subscribe(c_name).callback do
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
      pubsub = env[:redis].pubsub
      pubsub.subscribe(c).callback do 
        env[:channels] << c
        env.logger.info "subscribed to #{c}"
      end 
    end
  end

  def on_close(env)
    pub_sub = env[:redis].pubsub
    env[:channels].each { |c| pub_sub.unsubscribe(c) }
    env[:redis].close_connection
    env[:mongo].close
    env.logger.info("socket connection closed for #{env[:user_oid]}")
  end

  def on_error(env, error)
    env.logger.error error
  end

end