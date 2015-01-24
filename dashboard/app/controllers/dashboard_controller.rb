class DashboardController < ApplicationController
  respond_to :json
  before_action :authenticate_user!

  def show
    sensors = Sensor.where(user_id: current_user._id)
    sensors_json = sensors.each_with_object([]) do |s, arr|
      measurements = s.measurements.order('$natural' => -1).limit(20).to_a
      arr << {measurements: measurements.reverse}.merge(Hash[s.attributes].slice('_id', 'device_uid', 'device_name', 'created_at'))
    end
    render json: {
      current_user: current_user.as_json(only: [:_id, :email]),
      sensors: sensors_json
    }
  end
end