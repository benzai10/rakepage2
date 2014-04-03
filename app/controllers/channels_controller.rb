class ChannelsController < ApplicationController

  def index
    @channels = Channel.all
  end

  def new
    @channel = Channel.new
  end

  def create
    rake_id = params[:channel][:rake_id]
    rake_class = session[:rake_class]

    if params[:channel][:id].empty?
      @channel = Channel.new(channel_params)
      if @channel.save
        rake_class.find(rake_id).add_channel(@channel)
        redirect_to controller: rake_class.to_s.downcase + "s", action: "show", id: rake_id
        @channel.pull_source
      else
        flash[:error] = @channel.errors.full_messages
        redirect_to :back
      end
    else
      @channel = Channel.find(params[:channel][:id])
      rake_class.find(rake_id).add_channel(@channel)
      redirect_to controller: rake_class.to_s.downcase + "s", action: "show", id: rake_id
    end

  end

  def channel_params
    params.require(:channel).permit(:name, :channel_type, :source)
  end
end
