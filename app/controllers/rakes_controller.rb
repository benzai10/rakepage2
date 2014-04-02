class RakesController < ApplicationController

  def index
    Rake.find(:all, conditions: [ "user_id = ?", current_user.id ])
  end

  def show
    @rake = Rake.find(params[:id])
    @channels = @rake.channels.all
    @leaflets = Leaflet.where("channel_id IN (?)", @channels)
    @heap_leaflets = @rake.heap.leaflets
  end

  def new
    @rake = Rake.new
  end

  def create
    @rake = Rake.new(rake_params)
    if @rake.save
      redirect_to rake_path(@rake)
    else
      flash[:error] = @rake.errors.full_messages
      redirect_to :back
    end
  end

  def update
    @rake = Rake.find(params[:id])
    if !params[:channel].nil?
      channel = Channel.find(params[:channel])
      @rake.remove_channel(channel)
      redirect_to rake_path(@rake)
    end
  end

  def rake_params
    params.require(:rake).permit(:name, :master_rake_id, :user_id)
  end
end
