class DashboardController < ApplicationController
  respond_to :json
  before_action :authenticate_user!
  
  def a
    'b'
  end
end
