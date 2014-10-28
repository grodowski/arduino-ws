require 'rails_helper'

describe SensorsController do 
  include Devise::TestHelpers 
  
  let(:user) { create :user }
  before do 
    sign_in user
  end
  
  describe 'POST create' do 
    let(:sensor_attributes) { attributes_for :sensor }
    it 'creates a new sensor' do 
      expect {
        post :create, sensor: sensor_attributes, format: :json
      }.to change { user.reload.sensors_count }.by(1)
      response = JSON.parse(response.body)
    end
  end
  
  describe 'DELETE destroy' do 
    pending
    it 'removes a sensor' do
    
    end
  end
  
  describe 'PUT update' do 
    pending 
    it 'updates a sensor' do 
      
    end
  end
  
end