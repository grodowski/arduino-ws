# WebSocketSetupService does the heavy lifting behind initalizing WS connections
class WebsocketSetupService
  def self.call(env, mongo, redis)
    new(env, mongo, redis).call
  end

  private

  attr_reader :env, :mongo

  def initialize(env, mongo, redis)
    @env = env
    @env[:pubsub] = redis.pubsub
    @env[:channels] = []
    @env[:user_oid] = BSON::ObjectId(env['REQUEST_URI'].delete('/'))
    @mongo = mongo
  end

  def call
    setup_pubsub_handler
    with_sensors do |sensors|
      pubsub_subscr(sensors)
    end
  end

  private

  def pubsub_subscr(sensors)
    sensors.compact.each do |sensor| # sensors might have nils, d'oh
      c_name = sensor['device_uid']
      env[:pubsub].subscribe(c_name).callback do
        env[:channels] << (c_name)
        env.logger.info "subscribed to #{c_name}"
      end
    end
  end

  def setup_pubsub_handler
    env[:pubsub].on(:message) do |channel, msg|
      env.logger.info "#{channel}: #{msg}"
      env['handler'].send_text_frame msg
    end
  end

  def with_sensors
    yield SensorRepository.new(mongo, env[:user_oid]).all
  end
end
