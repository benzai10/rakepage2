class RakesController < ApplicationController

  def index
    session[:rake_class] = Rake
    if params[:heap] == "yes"
      session[:heap] = "yes"
    else
      session[:heap] = "no"
    end
    @rakes = Rake.where("user_id = ?", current_user.id)
    if @rakes.empty?
      redirect_to master_rakes_path
      return
    end
    #@rake = @rakes.first
    # if !params[:rake_id].nil?
    #   @rake = @rakes.where("id = ?", params[:rake_id].to_i).first
    #   if session[:heap] == "no"
    #     @rake.channels.each do |c|
    #       if Time.now - c.last_pull_at > 1200
    #         if c.channel_type == 1
    #           current_user.get_fb_news_feed
    #         else
    #           c.pull_source
    #         end
    #       end
    #     end
    #   end
    # end
    #@feed_leaflets = @rake.feed_leaflets("news").page(params[:page]).per(10)
    #@heaps = @rake.heaps
    #heap_ids = @heaps.pluck(:id)
    #leaflet_ids = HeapLeafletMap.where("heap_id IN (?)", heap_ids).pluck(:leaflet_id)
    #@heap_leaflets = Leaflet.where("id IN (?)", leaflet_ids)
    #@rake_filter = @rake.filters.map{ |f| f.keyword }.join(",")
    #@notifications = current_user.get_notifications
    category_ids = MasterRake.where("id IN (?)", @rakes.pluck(:master_rake_id)).pluck(:category_id).uniq
    @categories = Category.where("id IN (?)", category_ids)
  end

  def show
    # @rake = Rake.find(params[:id])
    # @heap_leaflets = @rake.heap.leaflets
    # @channels = @rake.channels.where("channel_type <> 1 AND channel_type <> 3")
    # session[:feed_type] = params[:feed_type]
    # @feed_leaflets = @rake.feed_leaflets(session[:feed_type]).page(params[:page]).per(10)
    # session[:rake_class] = @rake.class
    # respond_to do |format|
    #   format.html
    #   format.json
    # end
    session[:rake_class] = Rake
    if params[:heap] == "yes"
      session[:heap] = "yes"
    else
      session[:heap] = "no"
    end
    @rake = Rake.find(params[:id])
    if session[:heap] == "no"
      @rake.channels.each do |c|
        if Time.now - c.last_pull_at > 1200
          if c.channel_type == 1
            current_user.get_fb_news_feed
          else
            c.pull_source
          end
        end
      end
    end
    @feed_leaflets = @rake.feed_leaflets("news").page(params[:page]).per(10)
    @heaps = @rake.heaps
    heap_ids = @heaps.pluck(:id)
    leaflet_ids = HeapLeafletMap.where("heap_id IN (?)", heap_ids).pluck(:leaflet_id)
    @heap_leaflets = Leaflet.where("id IN (?)", leaflet_ids)
    @rake_filter = @rake.filters.map{ |f| f.keyword }.join(",")
    @notifications = current_user.get_notifications
  end

  def news
    @rake = Rake.find(params[:id])
    @heap_leaflets = @rake.heap.leaflets
    @channels = @rake.channels.where("channel_type <> 1 AND channel_type <> 3")
    session[:feed_type] = "news"
    @feed_leaflets = @rake.feed_leaflets(session[:feed_type]).page(params[:page]).per(10)
    session[:rake_class] = @rake.class
    respond_to do |format|
      format.html
      format.json
    end
  end

  def saved
    @rake = Rake.find(params[:id])
    @heap_leaflets = @rake.heap.leaflets
    @channels = @rake.channels.where("channel_type <> 1 AND channel_type <> 3")
    session[:feed_type] = "saved"
    @feed_leaflets = @rake.feed_leaflets(session[:feed_type]).page(params[:page]).per(10)
    session[:rake_class] = @rake.class
    respond_to do |format|
      format.html
      format.json
    end
  end

  def new
    @rake = Rake.new
    @master_rake = MasterRake.find_by_id(params[:master_rake_id].to_i)
    @channels = @master_rake.channels.where("channel_type <> 5")
    if session[:displayed_channels].nil? || session[:displayed_channels].empty?
      session[:displayed_channels] = @channels.pluck(:id)
    else
      if params[:display_channel] == "yes"
        session[:displayed_channels] << params[:channel_id].to_i
      else
        session[:displayed_channels].delete(params[:channel_id].to_i)
      end
    end
    @feed_leaflets = @master_rake.feed_leaflets.where("channel_id IN (?)", session[:displayed_channels]).page(params[:page]).per(10)
  end

  def create
    @rake = Rake.new(rake_params)
    if @rake.save
      MasterRake.find(@rake.master_rake_id).channels.each { |channel| @rake.add_channel(channel) unless channel.channel_type == 5 || !session[:displayed_channels].include?(channel.id) }
      filter_array = rake_params[:rake_filters].split(", ")
      filter_array.each do |f|
        @rake.add_filter(f, 1)
      end
      redirect_to rakes_path
    else
      flash[:error] = @rake.errors.full_messages
      redirect_to :back
    end
  end

  def edit
    @rake = Rake.find(params[:id])
    @master_rake = MasterRake.find_by_id(@rake.master_rake_id)
    @channels = @master_rake.channels.where("channel_type <> 5")
    if session[:displayed_channels].nil? || session[:displayed_channels].empty?
      session[:displayed_channels] = @channels.pluck(:id)
    else
      if params[:display_channel] == "yes"
        session[:displayed_channels] << params[:channel_id].to_i
      else
        session[:displayed_channels].delete(params[:channel_id].to_i)
      end
    end
    @feed_leaflets = @master_rake.feed_leaflets.where("channel_id IN (?)", session[:displayed_channels]).page(params[:page]).per(10)
  end

  def update
    @rake = Rake.find(params[:id])
    if params[:commit] == "Save Leaflet"
      leaflet = Leaflet.find(params[:rake][:leaflet_id])
      @rake.add_leaflet(leaflet, 
                        params[:rake][:leaflet_type_id],
                        params[:rake][:leaflet_title],
                        params[:rake][:leaflet_desc])
      redirect_to rakes_path(rake_id: @rake.id)
    elsif params[:commit] == "Create Leaflet"
      @rake.create_leaflet(params[:rake][:leaflet_type_id],
                           params[:rake][:leaflet_title],
                           params[:rake][:leaflet_desc],
                           params[:rake][:leaflet_url])
      redirect_to rakes_path(rake_id: @rake.id)
    else
      @rake.filters.each do |f|
        f.destroy
      end
      filter_array = rake_params[:rake_filters].split(", ")
      filter_array.each do |f|
        @rake.add_filter(f, 1)
      end
      redirect_to rakes_path(rake_id: @rake.id)
    end
  end

  def destroy
    rake = Rake.find_by_id(params[:id])
    rake.destroy
    redirect_to rakes_path, :notice => "Rake Deleted."
  end

  def add_channel
  end

  def remove_channel
    @rake = Rake.find(params[:id])
    if !params[:channel].nil?
      @channel = Channel.find(params[:channel])
      @rake.remove_channel(@channel)
      respond_to do |format|
        format.html { redirect_to rakes_path(rake_id: @rake.id) }
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
      format.html { redirect_to rakes_path(rake_id: @rake.id) }
    end
  end

  protected

  def rake_params
    params.require(:rake).permit(:name, :master_rake_id, :user_id, :feed_leaflets, :rake_filters)
  end
end
