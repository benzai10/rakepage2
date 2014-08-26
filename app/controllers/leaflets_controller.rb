class LeafletsController < ApplicationController

  def show
    @leaflet = Leaflet.find(params[:id])
  end

  def new
    @leaflet = Leaflet.new
    @channel_id = Myrake.find(params[:rake_id]).channels.where("channel_type = 3").first.id
  end

  def create
    @leaflet = Leaflet.new(leaflet_params)
    if @leaflet.save
      rake = Myrake.find(params[:leaflet][:rake_id])
      rake.heap.add_leaflet(@leaflet)
      redirect_to myrake_path(rake)
    else
      flash[:error] = @leaflet.errors.full_messages
      redirect_to :back
    end
  end

  def view_add
    unless params['leaflet']['id'].empty?
      Leaflet.increment_counter(:view_count, params['leaflet']['id']) 
    end
    render nothing: true
  end

  def like_add
    unless params['leaflet']['id'].empty?
      Leaflet.increment_counter(:like_count, params['leaflet']['id'])
      History.create(user_id: current_user.id, leaflet_id: params['leaflet']['id'].to_i, history_code: "liked")
    end
    render nothing: true
  end

  protected

  def leaflet_params
    params.require(:leaflet).permit(:channel_id, :name, :title, :content, :url, :image, :rake_id)
  end

end
