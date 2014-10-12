class Thermometer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :device_uid, type: String
end
