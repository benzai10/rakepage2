class Dashboard::MyrakesController < ApplicationController
    before_filter :authorize

  def index
    @myrakes = Myrake.first(10)
  end

  def authorize
    unless user_signed_in? && current_user.admin?
      flash[:error] = "unauthorized access"
      redirect_to master_rakes_path
      false
    end
  end

end