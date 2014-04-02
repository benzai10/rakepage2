class ChannelsController < ApplicationController

  def index
    @channels = Channel.all
  end

  def new
    @channel = Channel.new
  end

  def create
    master_rake_id = params[:channel][:master_rake_id]
    rake_id = params[:channel][:rake_id]
    if params[:channel][:id].empty?
      @channel = Channel.new(channel_params)
      if @channel.save
        if master_rake_id.nil?
          Rake.find(rake_id).add_channel(@channel)
          redirect_to rake_path(rake_id)
        else
          MasterRake.find(master_rake_id).add_channel(@channel)
          redirect_to master_rake_path(master_rake_id)
        end
      else
        flash[:error] = @channel.errors.full_messages
        redirect_to :back
      end
    else
      @channel = Channel.find(params[:channel][:id])
      if master_rake_id.nil?
        Rake.find(rake_id).add_channel(@channel)
        redirect_to rake_path(rake_id)
      else
        MasterRake.find(master_rake_id).add_channel(@channel)
        redirect_to master_rake_path(master_rake_id)
      end
    end
  end

  def channel_params
    params.require(:channel).permit(:name, :channel_type, :source)
  end
end
