class Sensor
  include Mongoid::Document
  include Mongoid::Timestamps
  field :device_uid, type: String
  field :device_name, type: String

  belongs_to :user
end
