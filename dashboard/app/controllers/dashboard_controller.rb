class DashboardController < ApplicationController
  respond_to :json
  before_action :authenticate_user!

  def show
    sensors = Sensor.where(user_id: current_user._id).slice(measurements: -20)
    render json: {
      current_user: current_user.as_json(only: [:_id, :email]),
      sensors: sensors
    }
  end
end