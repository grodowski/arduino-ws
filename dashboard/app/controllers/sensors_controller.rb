class SensorsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
  end

  def create
    sensor = current_user.sensors.build(sensor_params)
    if sensor.save
      respond_with sensor
    else
      render json: {errors: sensor.errors}, status: 422
    end
  end

  def update
    # TODO implement sensor settings
  end

  def destroy
    sensor = current_users.sensors.find(params[:id])
    sensor.destroy
    head 200, format: :json
  end
  
  private 
  
  def sensor_params
    params.require(:sensor).permit(:device_uid, :device_name)
  end
end