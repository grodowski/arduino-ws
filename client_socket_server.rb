require 'goliath'
require 'goliath/websocket'
require 'json'
require 'em-mongo'
require 'em-hiredis'

# usage 
# ruby client_socet_server.rb -sv -p 9001

class ClientSocketServer < Goliath::WebSocket
  attr_accessor :redis, :mongo, :db, :user_oid

  def on_open(env)
    @mongo = EM::Mongo::Connection.new('localhost')
    @db = mongo.db('dashboard_development')
    @redis = EM::Hiredis.connect

    pubsub = redis.pubsub
    @user_oid = BSON::ObjectId(env['REQUEST_URI'].gsub('/', ''))

    sensors = db.collection(:sensors).find(user_id: user_oid).defer_as_a
    sensors.callback do |arr|
      arr.each do |sensor|
        next unless sensor
        pubsub.subscribe('ard_t').callback do
          env.logger.info "subscribed to #{sensor['device_uid']}"
        end
        pubsub.on(:message) do |channel, msg|
          env.logger.info msg
          env['handler'].send_text_frame msg
        end
      end
    end

  end

  def on_message(env)

  end

  def on_close(env)
    redis.close_connection
    mongo.close
    env.logger.info('Socket connection closed')
  end

  def on_error(env, error)
    env.logger.error error
  end

end