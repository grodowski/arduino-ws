require 'goliath'
require 'goliath/websocket'
require 'em-hiredis'
require 'em-mongo'
require 'em-synchrony/em-mongo'
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

  def on_close(env)
    env.logger.info('Socket connection closed')
  end

  def on_error(env, error)
    env.logger.error error
  end
end
