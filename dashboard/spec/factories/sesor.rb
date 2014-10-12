FactoryGirl.define do
  factory :sensor do
    device_name 'Remote Sensor'
    device_uid 'S1234'

    measurements { [build(:measurement), build(:measurement)] }
  end
end