class Measurement
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :sensor

  field :temp_c, type: Float
end
