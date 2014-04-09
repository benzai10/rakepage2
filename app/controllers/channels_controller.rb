class ChannelsController < ApplicationController

  def index
    @channels = Channel.all
  end

  def show
  end

  def new
    @channel = Channel.new
  end

  def create
    rake_id = params[:channel][:rake_id]
    rake_class = session[:rake_class]
    if params[:channel][:id].empty?
      @channel = Channel.new(channel_params)
      begin
        if @channel.save
          rake_class.find(rake_id).add_channel(@channel)
          @channel.pull_source
          if rake_class == Rake
            redirect_to rake_path(rake_id)
          else
            redirect_to master_rake_path(rake_id)
          end
        else
          flash[:error] = @channel.errors.full_messages
          redirect_to :back
        end
      rescue FeedHelper::FeedNotFoundError => e
        flash[:error] = e.message
        redirect_to :back
      end
    else
      @channel = Channel.find(params[:channel][:id])
      rake_class.find(rake_id).add_channel(@channel)
      if rake_class == Rake
        redirect_to rake_path(rake_id)
      else
        redirect_to master_rake_path(rake_id)
      end
    end
  end

  def refresh_feed
    rake_class = session[:rake_class]
    rake = rake_class.find(params[:id])
    rake.channels.each do |c|
      c.pull_source
    end
    if session[:rake_class] == Rake
      redirect_to rake_path(params[:id])
    else
      redirect_to master_rake_path(params[:id])
    end
  end

  def channel_params
    params.require(:channel).permit(:name, :channel_type, :source)
  end
end
