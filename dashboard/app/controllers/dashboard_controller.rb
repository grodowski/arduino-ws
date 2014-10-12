class DashboardController < ApplicationController
  respond_to :json
  before_action :authenticate_user!

  def show
    result = Sensor.where(user_id: current_user.id).slice(measurements: -5)
    respond_with sensors: result
  end
end