class HistoriesController < ApplicationController

  def create
    if History.where("user_id = ? AND history_code = ?", current_user.id, "no_tutorial").count == 0
      @history = History.new
      @history.user_id = current_user.id
      @history.history_code = "no_tutorial"
      @history.save
    end
    redirect_to master_rakes_path
  end

end