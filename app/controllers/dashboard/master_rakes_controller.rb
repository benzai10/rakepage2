class Dashboard::MasterRakesController < ApplicationController
    before_filter :authorize

  def index
    @master_rakes = MasterRake.order('refreshed_at DESC NULLS LAST').page(params[:page]).per(50)
  end

  def show
    @master_rake = MasterRake.find(params[:id])
  end

  def authorize
    unless user_signed_in? && current_user.admin?
      flash[:error] = "unauthorized access"
      redirect_to master_rakes_path
      false
    end
  end

end