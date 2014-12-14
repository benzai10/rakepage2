class Dashboard::HistoriesController < ApplicationController
  before_filter :authorize

  def index
    @histories = History.first(10)
  end

  def authorize
    unless user_signed_in? && current_user.admin?
      flash[:error] = "unauthorized access"
      redirect_to master_rakes_path
      false
    end
  end

end