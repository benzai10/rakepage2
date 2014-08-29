class UsersController < ApplicationController

  def update
    if params[:commit] == "Save Recommendation"
      leaflet = Leaflet.find(params[:user][:leaflet_id])
      myrake = Myrake.where(user_id: current_user.id, name: params[:user][:rake_name]).first
      myrake.add_leaflet(leaflet, params[:user][:leaflet_type_id], leaflet.title, "")
      redirect_to master_rakes_path(collapse: "recommendations", anchor: "leaflet_" + leaflet.id.to_s)
    else
      redirect_to master_rakes_path
    end
  end

end