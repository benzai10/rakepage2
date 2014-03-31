class MasterRakesController < ApplicationController

  def index
    @master_rakes = MasterRake.all
  end

end
