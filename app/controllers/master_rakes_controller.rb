class MasterRakesController < ApplicationController

  def index
    @master_rakes = MasterRake.all
  end

  def new
    @master_rake = MasterRake.new
  end

  def create
  end

end
