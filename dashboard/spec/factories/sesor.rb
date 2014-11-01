FactoryGirl.define do
  factory :sensor do
    device_name 'Remote Sensor'
    sequence :device_uid do |n| 
      "S000#{n}"
    end
    measurements { [build(:measurement), build(:measurement)] }
  end
end