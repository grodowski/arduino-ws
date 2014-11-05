require 'goliath'
require 'goliath/websocket'
require 'em-hiredis'
require 'em-mongo'
require 'json'
require 'hashie'

if Goliath.env?(:development)
  require 'dotenv'
  Dotenv.load
end

# usage
# ruby device_socket_server.rb -sv -p 9000
# production:
# ruby device_socket_server.rb -l dashboard/log/device_socket.log -p 9000 -d -e production

class DeviceSocketServer < Goliath::WebSocket
  PAYLOAD_TYPES = %w(data)
  
  def on_open(env)
    env['mongo'] = EM::Mongo::Connection.new(ENV['DB_HOST'])
    env['db'] = env['mongo'].db(ENV['DB_NAME'])
    env['redis'] = EM::Hiredis.connect
    
    uid = env['REQUEST_URI'].gsub('/', '')
    s_req = env['db'].collection(:sensors).first({device_uid: uid})
    s_req.callback do |data|
      if data
        env['sensor'] = data
        env.logger.info "setup ready: sensor #{env['sensor']['device_uid']}"
      else
        env.logger.error "setup failed: unknown uid #{uid}."
        env['handler'].send_text_frame({e: "uid #{uid} unknown"}.to_json)
      end
    end
  end

  def on_message(env, msg)
    timestamp = Time.now
    data = Hashie::Mash.new(JSON.parse msg)
    unless env['sensor'] && PAYLOAD_TYPES.include?(data.type) && data.temp_c
      env.logger.info 'sensor not initialised or wrong format'
      return 
    end
    
    env['db'].collection(:sensors).update(
      {device_uid: env['sensor']['device_uid']},
      {'$push' => 
        {measurements: 
          {temp_c: data.temp_c, created_at: timestamp, updated_at: timestamp}
        }
      }
    )
    
    data_json = data.merge({device_uid: env['sensor']['device_uid'], created_at: timestamp.iso8601, updated_at: timestamp.iso8601}).to_json
    env['redis'].publish env['sensor']['device_uid'], data_json

    env.logger.info "#{env['sensor']['device_uid']} - temp: #{data.temp_c}"
    env['handler'].send_text_frame({r: 'OK'}.to_json)
  end

  def on_close(env)
    env['redis'].close_connection
    env['mongo'].close
    env.logger.info('Socket connection closed')
  end

  def on_error(env, error)
    env.logger.error error
  end
end
