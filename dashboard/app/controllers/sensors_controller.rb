class SensorsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show 
    offset = params[:offset].to_i || 0
    limit = params[:limit].to_i || 5000
    sensor = Sensor.find(params[:id])
    measurements = Measurement.where(sensor_id: sensor[:_id]).order({'$natural' => -1}).skip(offset).limit(limit).as_json
    
    actual_measurements = measurements.size
    
    level = 10
    cluster = []
    for i in 0..(actual_measurements)
      next if i % level != 0
      chunk = measurements[i..(i + level -1)].compact
      next if chunk.empty?
      temp_c = (chunk.map { |x| x['temp_c'] }.reduce(:+) / chunk.size).round(2)
      cluster << {
        temp_c: temp_c,
        created_at: measurements[i]['created_at']
      }
    end
    
    sensor_json = sensor.as_json 
    sensor_json[:measurements] = cluster.reverse
    render json: {
      sensor: sensor_json,
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