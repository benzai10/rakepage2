class ChannelsController < ApplicationController

  def index
    @channels = Channel.all
  end

  def new
    @channel = Channel.new
  end

  def create
    @channel = Channel.new(channel_params)
    if @channel.save
      MasterRake.find(params[:channel][:master_rake_id]).add_channel(@channel)
      redirect_to master_rake_path(params[:channel][:master_rake_id])
    else
      flash[:error] = @channel.errors.full_messages
      redirect_to :back
    end
  end

  def channel_params
    params.require(:channel).permit(:name, :channel_type, :source)
  end
end
