class Dashboard::HeapLeafletMapsController < ApplicationController
  before_filter :authorize

  def index
    if params[:view] == "due_tasks"
      @tasks = HeapLeafletMap.where("reminder_at < ?", Time.now).order(reminder_at: :asc).page(params[:page]).per(50)
    elsif params[:view] == "no_reminder_tasks"
      leaflet_ids = History.where(history_code: "bm_activity").pluck(:leaflet_id)
      @tasks_without_reminder = HeapLeafletMap.where("reminder_at IS NULL AND leaflet_id IN (?)", leaflet_ids).page(params[:page]).per(50)
    else
      @tasks = HeapLeafletMap.all.page(params[:page]).per(50)
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