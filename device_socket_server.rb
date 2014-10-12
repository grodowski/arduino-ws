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
  attr_accessor :mongo, :redis

  def on_open(env)
    @mongo = EM::Mongo::Connection.new('localhost').db('dashboard_development')
    @redis = EM::Hiredis.connect
    env.logger.info 'Setup ready'
  end

  def on_message(env, msg)
    # incoming JSON format (from device)
    # {'type': 'data', 'temp_c': '12.33'}
    timestamp = Time.now
    data = Hashie::Mash.new(JSON.parse msg)
    return unless PAYLOAD_TYPES.include? data.type
    
    sensor = mongo.collection(:sensors).first({device_uid: data.device_uid})
    unless sensor 
      env.logger.error "Unknown uid #{data.device_uid}."
      return
    end
    
    mongo.collection(:sensors).update(
      {device_uid: data.device_uid},
      {'$push' => 
        {measurements: 
          {temp_c: data.temp_c, created_at: timestamp, updated_at: timestamp}
        }
      }
    )
    data_json = data.merge({created_at: timestamp, updated_at: timestamp}).to_json
    redis.publish "#{data.device_uid}_#{data.type}", data_json
    env.logger.info data.temp_c  
    env['handler'].send_text_frame 'OK'
  end

  def on_close(env)
    env.logger.info('Socket connection closed')
  end

  def on_error(env, error)
    env.logger.error error
  end
end
