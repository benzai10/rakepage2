class RakesController < ApplicationController

  def show
    @leaflets = Leaflet.all
    @channels = Channel.all
  end

end
