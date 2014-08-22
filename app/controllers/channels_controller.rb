class ChannelsController < ApplicationController

  autocomplete :channel, :source, :full => true

  def index
    @channels = Channel.all
  end

  def show
  end

  def new
    @channel = Channel.new
    respond_to do |format|
      format.json
    end
  end

  def create
    rake_id = params[:channel][:rake_id]
    rake_class = session[:rake_class]
    if Channel.search_by_source(params[:channel][:source]).nil?
      begin
        @channel = Channel.new(channel_params)
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
      @channel = Channel.search_by_source(params[:channel][:source])
      rake_class.find(rake_id).add_channel(@channel)
      if rake_class == Rake
        redirect_to rake_path(rake_id)
      else
        redirect_to master_rake_path(rake_id)
      end
    end
  end

  def refresh_feed
    session[:feed_type] = params[:feed_type]
    rake_class = session[:rake_class]
    rake = rake_class.find(params[:id])
    if session[:feed_type] == "saved"
      rake.update_attribute(:saved_refreshed_at, DateTime.now) unless rake_class == MasterRake
    else
      rake.update_attribute(:refreshed_at, DateTime.now) unless rake_class == MasterRake
      rake.channels.each do |c|
        c.pull_source
      end
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
