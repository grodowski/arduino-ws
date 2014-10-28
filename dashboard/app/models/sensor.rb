class Sensor
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  embeds_many :measurements

  field :device_uid, type: String
  field :device_name, type: String
  
  validates :device_uid, :device_name, presence: true
  validates :device_uid, uniqueness: true
end
