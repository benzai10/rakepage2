class UsersController < ApplicationController

  def update
    if params[:commit] == "Save Bookmark"
      leaflet = Leaflet.find(params[:user][:leaflet_id])
      myrake = Myrake.where(user_id: current_user.id, name: params[:user][:rake_name]).first
      myrake.add_leaflet(leaflet, params[:user][:leaflet_type_id], leaflet.title, "", nil)
      redirect_to master_rakes_path(collapse: "recommendations", anchor: "leaflet_" + leaflet.id.to_s)
    elsif params[:commit] == "Update Bookmark"
      leaflet = Leaflet.find(params[:user][:leaflet_id])
      heap_leaflet = HeapLeafletMap.where("heap_id = ? AND leaflet_id = ?", 
                                          params[:user][:heap_id].to_i, 
                                          params[:user][:leaflet_id].to_i).first
      case params[:user][:reminder_at].to_i
      when 0
        reminder_at = nil
      when 1
        reminder_at = Time.now + 1.hour
      when 2
        reminder_at = Time.now + 1.day
      when 3
        reminder_at = Time.now + 3.day
      when 4
        reminder_at = Time.now + 1.week
      when 5
        reminder_at = Time.now + 1.month
      else
        reminder_at = nil
      end
      heap_leaflet.update_attributes(leaflet_title: params[:user][:leaflet_title],
                                     leaflet_desc: params[:user][:leaflet_desc],
                                     leaflet_goal: params[:user][:leaflet_goal],
                                     leaflet_note: params[:user][:leaflet_note],
                                     reminder_at: reminder_at,
                                     current_score: params[:user][:current_score].to_i,
                                     current_reminder: params[:user][:current_reminder])
      History.create(user_id: current_user.id,
                     leaflet_id: leaflet.id,
                     history_code: "bookmark",
                     history_int: params[:user][:current_score].to_i,
                     history_str: params[:user][:current_reminder])
      redirect_to myrakes_path(collapse: "reminders")
    else
      redirect_to master_rakes_path
    end
  end

end