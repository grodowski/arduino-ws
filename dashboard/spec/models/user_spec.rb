require 'rails_helper'

describe User do
  it 'has many sensors' do
    user = create :user
    sensor = user.sensors.create attributes_for(:sensor)
    expect(sensor).to be_persisted
    expect(user.sensors.count).to eq 1
  end
end