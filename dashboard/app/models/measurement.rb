class Measurement
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :sensor

  field :temp_c, type: Float
end
