class Dashboard::HeapLeafletMapsController < ApplicationController
  before_filter :authorize

  def index
    if params[:view] == "due_tasks"
      @tasks = HeapLeafletMap.where("reminder_at < ?", Time.now).order(reminder_at: :asc).page(params[:page]).per(20)
    else
      @tasks = HeapLeafletMap.all.page(params[:page]).per(20)
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