require 'goliath'
require 'goliath/websocket'
require 'grape'
require 'redis'
require 'json'
require 'em-mongo'

class Server < Goliath::WebSocket
  PAYLOAD_TYPES = %w(data)
  attr_accessor :db

  def on_open(env)
    @db = EM::Mongo::Connection.new('localhost').db('ard_dashboard')
    env.logger.info 'Setup ready'
  end

  def on_message(env, msg)
    # JSON format
    # {'type': 'data', 'temp_c': '12.33'}
    data = Hashie::Mash.new(JSON.parse msg)
    return unless PAYLOAD_TYPES.include? data.type
    db.collection('measurements').insert data
    env['handler'].send_text_frame 'OK'
  end

  def on_close(env)
    env.logger.info('Socket connection closed')
  end

  def on_error(env, error)
    puts error
  end
end
