class RakesController < ApplicationController

  def index
    if current_user.nil?
      redirect_to master_rakes_path
      return
    end
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
    category_ids = MasterRake.where("id IN (?)", @rakes.pluck(:master_rake_id)).pluck(:category_id).uniq
    @categories = Category.where("id IN (?)", category_ids)
    if !params[:category_id].nil?
      @category = Category.find(params[:category_id].to_i)
    end
    @authentications = current_user.authentications
    current_user.import_fb unless @authentications.find_by(provider: "facebook").nil?
    @new_master_rakes = MasterRake.all.order(created_at: :desc).limit(12)
    @new_leaflets = Leaflet.where("id IN (?)",
                            HeapLeafletMap.limit(50).pluck(:leaflet_id)).order(created_at: :desc)
  end

  def show
    session[:rake_class] = Rake
    if params[:heap] == "yes"
      session[:heap] = "yes"
    else
      session[:heap] = "no"
    end
    @rake = Rake.find(params[:id])
    #@rake.feed_leaflets("news", params[:refresh])
    #@feed_leaflets = Leaflet.where("id IN (?)", 
    #                 Feed.where(rake_id: @rake.id).pluck(:leaflet_id)).order("published_at DESC").page(params[:page]).per(10)
    @feed_leaflets = @rake.feed_leaflets("news", params[:refresh]).order("published_at DESC").page(params[:page]).per(50)
    @heaps = @rake.heaps
    heap_ids = @heaps.pluck(:id)
    leaflet_ids = HeapLeafletMap.where("heap_id IN (?)", heap_ids).pluck(:leaflet_id)
    @heap_leaflets = Leaflet.where("id IN (?)", leaflet_ids)
    @rake_filter = @rake.filters.map{ |f| f.keyword }.join(",")
    #@notifications = current_user.get_notifications
    params[:heap_type] ||= "News"
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
    if !params[:master_rake_id].nil?
      @master_rake = MasterRake.find_by_id(params[:master_rake_id].to_i)
      @channels = @master_rake.channels.where("channel_type <> 5")
    end
  end

  def create
    @rake = Rake.new(rake_params)
    if @rake.save
      #MasterRake.find(@rake.master_rake_id).channels.each { |channel| @rake.add_channel(channel) unless channel.channel_type == 5 || !session[:displayed_channels].include?(channel.id) }
      MasterRake.find(@rake.master_rake_id).channels.each { |channel| @rake.add_channel(channel) unless channel.channel_type == 5 }
      #MasterRake.find(@rake.master_rake_id).add_channel(@rake.channels.where(channel_type: 3).first)
      redirect_to rake_path(@rake, refresh: "yes")
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
      if session[:rake_class] == MasterRake
        redirect_to master_rake_path(@rake.master_rake_id)
      else
        redirect_to rake_path(@rake)
      end
    elsif params[:commit] == "Create Leaflet"
      begin
        @rake.create_leaflet(params[:rake][:leaflet_type_id],
                           params[:rake][:leaflet_title],
                           params[:rake][:leaflet_desc],
                           params[:rake][:leaflet_url])
        redirect_to rake_path(@rake, heap_type: params[:rake][:leaflet_type_id])
      rescue
        flash[:error] = "Error occured. Try again and make sure you fill in all fields."
        redirect_to rake_path(@rake, heap_type: params[:rake][:leaflet_type_id])
      end
    elsif params[:commit] == "Add Heap"
      @rake.add_heap(params[:rake][:leaflet_type_id])
      redirect_to rake_path(@rake, heap_type: params[:rake][:leaflet_type_id])
    else
      @rake.filters.each do |f|
        f.destroy
      end
      filter_array = rake_params[:rake_filters].split(", ")
      filter_array.each do |f|
        @rake.add_filter(f, 1)
      end
      redirect_to rake_path(@rake)
    end
  end

  def destroy
    rake = Rake.find_by_id(params[:id])
    rake.destroy
    redirect_to rakes_path, :notice => "Rake Deleted."
  end

  def add_channel
    @rake = Rake.find(params[:id])
    @rake.add_channel(Channel.find(params[:channel]))
    redirect_to rake_path(@rake)
  end

  def remove_channel
    @rake = Rake.find(params[:id])
    if !params[:channel].nil?
      @channel = Channel.find(params[:channel])
      @rake.remove_channel(@channel)
      respond_to do |format|
        format.html { redirect_to rake_path(@rake.id) }
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
      format.html { redirect_to rake_path(rake_id: @rake.id) }
    end
  end

  protected

  def rake_params
    params.require(:rake).permit(:name, :master_rake_id, :user_id, :feed_leaflets, :rake_filters)
  end
end
