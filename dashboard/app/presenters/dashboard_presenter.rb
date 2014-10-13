class DashboardPresenter
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def recent_measurements(sensor, limit = 5)
    sensor.measurements.desc(:created_at).limit(limit)
  end

  def as_json(opts = {})
    res = {current_user: user.as_json(only: [:_id, :email]), sensors: []}
    user.sensors.each_with_object res do |sensor, hash|
      measurements = {measurements: recent_measurements(sensor)}
      hash[:sensors] << sensor.as_json.merge!(measurements)
    end
  end
end