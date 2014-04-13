class LeafletsController < ApplicationController

  def show
    @leaflet = Leaflet.find(params[:id])
  end

  def new
    @leaflet = Leaflet.new
    @channels = Rake.find(params[:rake_id]).channels
  end

  def create
    @leaflet = Leaflet.new(leaflet_params)
    if @leaflet.save
      rake = Rake.find(params[:leaflet][:rake_id])
      rake.heap.add_leaflet(@leaflet)
      redirect_to rake_path(rake)
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

  protected

  def leaflet_params
    params.require(:leaflet).permit(:channel_id, :name, :title, :content, :url, :image, :rake_id)
  end

end
