require 'goliath'
require 'goliath/websocket'
require 'grape'
require 'redis'
require 'json'
require './api/publisher'

class Server < Goliath::WebSocket
  attr_accessor :redis, :redis_sub_thread

  def on_open(env)
    puts 'received on_open'
    setup(env)
    puts 'ws ready!'
  end

  def on_message(env, msg)
    env.logger.info 'received on_message with ' + msg
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
          begin
            data = JSON.parse msg
            puts 'received redis command' + msg
            env['handler'].send_text_frame msg
            puts 'sent frame!'
          rescue => e
            puts e.message
          end
        end
      end
    end
  end

end
