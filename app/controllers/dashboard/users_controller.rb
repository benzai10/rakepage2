class Dashboard::UsersController < ApplicationController
  before_filter :authorize

  def index
    @users = User.order('last_sign_in_at DESC NULLS LAST').page(params[:page]).per(50)
  end

  def show
    @user = User.find(params[:id])
  end

  def authorize
    unless user_signed_in? && current_user.admin?
      flash[:error] = "unauthorized access"
      redirect_to master_rakes_path
      false
    end
  end
end