class ChannelsController < ApplicationController

  def index
    @channels = Channel.all
  end

  def new
    if user_signed_in?
      @channel = Channel.new
    end
  end

  def create
    @channel = Channel.new(channel_params)
    if @channel.save
      redirect_to :back
    else
      flash[:error] = @channel.errors.full_messages
      redirect_to :back
    end
  end

  def channel_params
    params.require(:channel).permit(:name, :channel_type, :source)
  end
end
