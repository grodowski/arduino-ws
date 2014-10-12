require 'rails_helper'

describe DashboardController do
  include Devise::TestHelpers

  let(:user) { create :user }
  before do
    sign_in user
  end

  context 'GET index' do
    it 'renders sensor data for current user' do
      2.times { user.sensors.create(attributes_for(:sensor)) }
      get :show, format: :json
      body = JSON.parse(response.body)
      expect(body['sensors'].count).to eq 2
      expect(body['sensors'][0]['measurements'].first['temp_c']).to eq 12.5
    end

    it 'raises error for html mime' do
      expect {
        get :show
      }.to raise_error(ActionController::UnknownFormat)
    end
  end

end