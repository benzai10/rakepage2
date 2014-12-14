class Dashboard::HistoriesController < ApplicationController
  before_filter :authorize

  def index
    if params[:view] == "requests"
      @histories = History.where(history_code: "request").order(created_at: :desc).page(params[:page]).per(20)
    else
      @histories = History.order(created_at: :desc).page(params[:page]).per(20)
    end
  end

  def authorize
    unless user_signed_in? && current_user.admin?
      flash[:error] = "unauthorized access"
      redirect_to master_rakes_path
      false
    end
  end

end