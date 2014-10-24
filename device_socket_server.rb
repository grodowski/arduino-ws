require 'goliath'
require 'goliath/websocket'
require 'em-hiredis'
require 'json'
require 'em-mongo'
require 'hashie'

# usage
# ruby device_socket_server.rb -sv -p 9000

class DeviceSocketServer < Goliath::WebSocket
  PAYLOAD_TYPES = %w(data)
  attr_accessor :mongo, :db, :redis, :sensor

  def on_open(env)
    @mongo = EM::Mongo::Connection.new('localhost')
    @db = mongo.db('dashboard_development')
    @redis = EM::Hiredis.connect
    
    uid = env['REQUEST_URI'].gsub('/', '')
    s_req = db.collection(:sensors).first({device_uid: uid})
    s_req.callback do |data|
      if data
        @sensor = data
        env.logger.info "setup ready: sensor #{sensor['device_uid']}"
      else
        env.logger.error "setup failed: unknown uid #{uid}."
        env['handler'].send_text_frame({e: "uid #{uid} unknown"}.to_json)
      end
    end
  end

  # TODO: refactor to a SocketHandler class when more logic is needed
  # incoming JSON format (from device)
  # {'t: 'data', 'c': 12.33}
  def on_message(env, msg)
    timestamp = Time.now
    data = Hashie::Mash.new(JSON.parse msg)
    unless sensor && PAYLOAD_TYPES.include?(data.type) && data.temp_c
      env.logger.info 'sensor not initialised or wrong format'
      return 
    end
    
    db.collection(:sensors).update(
      {device_uid: sensor['device_uid']},
      {'$push' => 
        {measurements: 
          {temp_c: data.temp_c, created_at: timestamp, updated_at: timestamp}
        }
      }
    )
    
    data_json = data.merge({device_uid: sensor['device_uid'], created_at: timestamp.iso8601, updated_at: timestamp.iso8601}).to_json
    redis.publish sensor['device_uid'], data_json

    env['handler'].send_text_frame({r: 'OK'}.to_json)
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
