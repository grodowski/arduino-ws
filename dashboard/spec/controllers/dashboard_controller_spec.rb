require 'rails_helper'

describe DashboardController do
  include Devise::TestHelpers

  let(:user) { create :user }
  before do
    sign_in user
  end

  context 'GET index' do
    it 'renders sensor and data for current user' do
      2.times { |n| user.sensors.push(build(:sensor, device_uid: "device_#{n}")) }
      get :show, format: :json
      body = JSON.parse(response.body)
      expect(body['current_user']['email']).to eq user.email
      expect(body['sensors'].count).to eq 2
      expect(body['sensors'][0]['measurements'].first['temp_c']).to eq 12.5
    end
  end

end