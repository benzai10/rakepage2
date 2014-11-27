class HistoriesController < ApplicationController

  def create
    if user_signed_in?
      user_id = current_user.id
    else
      user_id = nil
    end
    params[:history][:rake_id] == "" ? rake_id = nil : rake_id = params[:history][:rake_id]
    params[:history][:master_rake_id] == "" ? master_rake_id = nil : master_rake_id = params[:history][:master_rake_id]
    History.create!(user_id: user_id,
                   master_rake_id: master_rake_id,
                   rake_id: rake_id,
                   history_code: "request",
                   history_text: params[:history][:history_text],
                   history_str: params[:history][:history_str])
    respond_to do |format|
      format.html {
        if !rake_id.nil?
          redirect_to myrake_path(rake_id)
          return
        elsif !master_rake_id.nil?
          redirect_to master_rake_path(master_rake_id)
          return
        else
          redirect_to master_rakes_path
          return
        end
      }
      format.js { render 'shared/request' }
    end
  end
end