class Sensor
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  embeds_many :measurements

  field :device_uid, type: String
  field :device_name, type: String
end
