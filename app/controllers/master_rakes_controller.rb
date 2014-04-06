class MasterRakesController < ApplicationController

  def index
    @master_rakes = MasterRake.all
    session[:rake_class] = MasterRake
  end

  def show
    @rake = MasterRake.find(params[:id])
    session[:rake_class] = MasterRake
    respond_to do |format|
      format.html
      format.json
    end
  end

  def new
    @master_rake = MasterRake.new
  end

  def create
    @master_rake = MasterRake.new(master_rake_params)
    if @master_rake.save
      redirect_to master_rakes_path
    else
      flash[:error] = @master_rake.errors.full_messages
      redirect_to :back
    end
  end

  def edit
    @master_rake = MasterRake.find(params[:id])
  end

  def update
    @master_rake = MasterRake.find(params[:id])
  end

  protected

  def master_rake_params
    params.require(:master_rake).permit(:name)
  end
end
