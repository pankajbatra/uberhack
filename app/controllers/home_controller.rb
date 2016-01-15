class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token
  def index
    current_user
  end

  def update
    current_user.mobile= params[:mobile]
    current_user.home= params[:home]
    current_user.office= params[:office]
    current_user.save!
  end
end
