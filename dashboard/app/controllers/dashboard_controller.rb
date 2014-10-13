class DashboardController < ApplicationController
  respond_to :json
  before_action :authenticate_user!

  def show
    respond_with DashboardPresenter.new(current_user)
  end
end