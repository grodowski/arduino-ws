class SensorsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show 
    offset = params[:offset].to_i || 50
    limit = params[:limit].to_i || offset
    sensor = Sensor.where(_id: params[:id]).slice(measurements: [offset, limit]).first
    render json: sensor
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