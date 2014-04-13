class RakesController < ApplicationController

  def index
    session[:rake_class] = Rake
    @rakes = Rake.find(:all, conditions: [ "user_id = ?", current_user.id ])
  end

  def show
    @rake = Rake.find(params[:id])
    @heap_leaflets = @rake.heap.leaflets
    @channels = @rake.channels.where("channel_type <> 1 AND channel_type <> 3")
    @feed_leaflets = @rake.feed_leaflets(session[:feed_type]).page(params[:page]).per(10)
    session[:rake_class] = @rake.class
    respond_to do |format|
      format.html
      format.json
    end
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

  def add_channel
  end

  def remove_channel
    @rake = Rake.find(params[:id])
    if !params[:channel].nil?
      @channel = Channel.find(params[:channel])
      @rake.remove_channel(@channel)
      respond_to do |format|
        format.html { redirect_to rake_path(@rake) }
        format.js { render 'remove_channel' }
      end
    end
  end

  def toggle_channel_display
    @rake = Rake.find(params[:id])
    @channel = Channel.find(params[:channel])
    display = params[:display] == "true"
    @rake.toggle_channel_display(@channel, display)
    respond_to do |format|
      format.html { redirect_to rake_path(@rake) }

    end
  end

  protected

  def rake_params
    params.require(:rake).permit(:name, :master_rake_id, :user_id, :feed_leaflets)
  end
end
