require 'goliath'
require 'goliath/websocket'
require 'em-hiredis'
require 'em-mongo'
require 'em-synchrony/em-mongo'
require 'json'
require 'hashie'

require './app/sensor_repository'
require './app/websocket_setup_service'

if Goliath.env?(:development)
  require 'dotenv'
  Dotenv.load
end

# dev:
# ruby client_socet_server.rb -sv -p 9001
# production:
# ruby client_socket_server.rb -l dashboard/log/client_socket.log \
# -p 9001 -d -e production
class ClientSocketServer < Goliath::WebSocket
  def on_open(env)
    WebSocketSetupService.call(env, db, redis)
  end

  def on_message(env, msg)
    body = Hashie::Mash.new(JSON.parse msg)
    return unless body.type == 'subscr'
    c = body.device_uid
    env[:pubsub].subscribe(c).callback do
      env[:channels] << c
      env.logger.info "subscribed to #{c}"
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
