class LeafletsController < ApplicationController

  def show
    @leaflet = Leaflet.find(params[:id])
  end
end
