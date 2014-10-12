require 'goliath'
require 'goliath/websocket'
require 'grape'
require 'redis'
require 'json'
require './api/publisher'

class Server < Goliath::WebSocket
  attr_accessor :redis, :redis_sub_thread

  PAYLOAD_TYPES = %w(data)

  def on_open(env)
    setup(env)
    env.logger.info 'Setup ready'
  end

  def on_message(env, msg)
    # format
    # {'type': 'data', 'temp_c': '12.33'}
    data = Hashie::Mash.new(JSON.parse msg)
    return unless PAYLOAD_TYPES.include? data.type

    # save data to the db (mongo or mysql)
    env.logger.info 'received data' + data.temp_c.to_s

    # echo the message back to the client
    env['handler'].send_text_frame msg
  end

  def on_close(env)
    if websocket?
      Thread.kill(redis_sub_thread)
      env.logger.info("WebSocket connection closed...")
    end
  end

  def on_error(env, error)
    puts error
  end

  def response(env)
    if websocket?
      super(env)
    else
      API::Publisher.call(env)
    end
  end

  private

  def websocket?
    env['REQUEST_PATH'] == '/ws'
  end

  def setup(env)
    @redis ||= Redis.new
    @redis_sub_thread = Thread.new do
      puts 'subscribing...'
      redis.subscribe 'test-channel' do |on|
        on.message do |channel, msg|
          data = JSON.parse msg
          env['handler'].send_text_frame msg
        end
      end
    end
  end

end
