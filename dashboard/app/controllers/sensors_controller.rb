class SensorsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show 
    offset = params[:offset].to_i || 50
    limit = params[:limit].to_i || offset
    sensor = Sensor.where(_id: params[:id]).slice(measurements: [offset, limit]).first.as_json
    
    actual_measurements = sensor['measurements'].size
    
    level = 10
    cluster = []
    for i in 0..(sensor['measurements'].size)
      next if i % level != 0
      chunk = sensor['measurements'][i..(i + level -1)].compact
      next if chunk.empty?
      temp_c = (chunk.map { |x| x['temp_c'] }.reduce(:+) / chunk.size).round(2)
      cluster << {
        temp_c: temp_c,
        created_at: sensor['measurements'][i]['created_at']
      }
    end
    
    sensor['measurements'] = cluster
    render json: {
      sensor: sensor,
      clustered: true,
      measurements_count: actual_measurements
    }
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