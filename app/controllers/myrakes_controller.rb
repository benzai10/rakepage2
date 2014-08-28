class MyrakesController < ApplicationController

  def index
    if current_user.nil?
      redirect_to master_rakes_path
      return
    end
    session[:rake_class] = Myrake
    if params[:heap] == "yes"
      session[:heap] = "yes"
    else
      session[:heap] = "no"
    end
    @rakes = Myrake.where("user_id = ?", current_user.id)
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
    @new_master_rakes = MasterRake.limit(13).order(created_at: :desc).limit(12)
    heap_ids = []
    @rakes.each do |r|
      heap_ids << r.heaps.pluck(:id)
    end
    heap_ids = heap_ids.flatten
    @new_leaflets = Leaflet.where("id IN (?) AND leaflet_type_id <> 15",
                            HeapLeafletMap.where("heap_id IN (?)", heap_ids).pluck(:leaflet_id)).order(created_at: :desc).limit(50)
  end

  def show
    session[:rake_class] = Myrake
    if params[:heap] == "yes"
      session[:heap] = "yes"
    else
      session[:heap] = "no"
    end
    params[:heap_type] ||= "News"
    @rake = Myrake.find(params[:id])
    @feed_leaflets = @rake.feed_leaflets("news", params[:refresh]).order("published_at DESC").page(params[:page]).per(50)
    @leaflet_types = CategoryLeafletTypeMap.where(category_id: @rake.master_rake.category_id).pluck(:leaflet_type_id)
    if !@rake.heaps.pluck(:leaflet_type_id).include?(params[:heap_type].to_i)
      @rake.add_heap(params[:heap_type].to_i)
    end
    @heaps = @rake.heaps
    @heap_ids = @heaps.pluck(:id)
    @leaflet_ids = HeapLeafletMap.where("heap_id IN (?)", @heap_ids).pluck(:leaflet_id)
    @heap_leaflets = Leaflet.where("id IN (?)", @leaflet_ids)
    @rake_filter = @rake.filters.map{ |f| f.keyword }.join(",")
    @feed_collapse = params[:collapse] == "feed" ? "in" : ""
  end

  def news
    @rake = Myrake.find(params[:id])
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
    @rake = Myrake.find(params[:id])
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
    @rake = Myrake.new
    if !params[:master_rake_id].nil?
      @master_rake = MasterRake.find_by_id(params[:master_rake_id].to_i)
      @channels = @master_rake.channels.where("channel_type <> 5")
    end
  end

  def create
    existing_rake = Myrake.where(user_id: current_user.id).find_by_master_rake_id(params[:myrake][:master_rake_id].to_i)
    if existing_rake.nil?
      @rake = Myrake.new(rake_params)
      if @rake.save
        master_rake = MasterRake.find(@rake.master_rake_id)
        master_rake.channels.each { |channel| @rake.add_channel(channel) unless channel.channel_type == 5 }
        master_rake.add_channel(@rake.channels.where(channel_type: 3).first)
        if params[:myrake][:copy_recommendations] == "1"
          rake_ids = master_rake.myrakes.pluck(:id)
          @heaps = Heap.where("myrake_id IN (?)", rake_ids)
          @heap_types = @heaps.pluck(:leaflet_type_id).uniq
          heap_ids = []
          master_rake.myrakes.each do |r|
            heap_ids << r.heaps.pluck(:id)
          end
          @heap_leaflets = Leaflet.where("id IN (?)", HeapLeafletMap.where("heap_id IN (?)", heap_ids.flatten).pluck(:leaflet_id).flatten).order("updated_at DESC").uniq
          @heap_leaflets_maps = HeapLeafletMap.where("leaflet_id IN (?)", @heap_leaflets.map(&:id))
          @heap_leaflets_maps.each do |hl|
            leaflet = Leaflet.find(hl.leaflet_id)
            @rake.add_leaflet(leaflet, leaflet.leaflet_type_id, leaflet.title, "")
          end
        end
        redirect_to myrake_path(@rake, refresh: "yes")
      else
        flash[:error] = @rake.errors.full_messages
        redirect_to :back
      end
    else
      redirect_to myrake_path(existing_rake)
    end
  end

  def edit
    @rake = Myrake.find(params[:id])
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
    @rake = Myrake.find(params[:id])
    if params[:commit] == "Update Leaflet"
      leaflet = Leaflet.find(params[:myrake][:id])
      heap_leaflet = HeapLeafletMap.where("heap_id = ? AND leaflet_id = ?", 
                                          params[:myrake][:heap_id].to_i, 
                                          params[:myrake][:id].to_i).first
      heap_leaflet.update_attributes(leaflet_title: params[:myrake][:leaflet_title], leaflet_desc: params[:myrake][:leaflet_desc])
      leaflet.update_attributes(title: params[:myrake][:leaflet_title], content: params[:myrake][:leaflet_desc], url: params[:myrake][:leaflet_url])
      redirect_to myrake_path(@rake, collapse: params[:myrake][:collapse], anchor: "leaflet-" + params[:myrake][:id])
    elsif params[:commit] == "Save Leaflet"
      leaflet = Leaflet.find(params[:myrake][:leaflet_id])
      @rake.add_leaflet(leaflet, 
                        params[:myrake][:leaflet_type_id],
                        params[:myrake][:leaflet_title],
                        params[:myrake][:leaflet_desc])
      if session[:rake_class] == MasterRake
        redirect_to master_rake_path(@rake.master_rake_id, collapse: params[:myrake][:collapse], anchor: "leaflet_" + params[:myrake][:leaflet_id])
      else
        redirect_to myrake_path(@rake, collapse: params[:myrake][:collapse], anchor: "leaflet-" + params[:myrake][:leaflet_id])
      end
    elsif params[:commit] == "Create Leaflet"
      if @rake.create_leaflet(params[:myrake][:leaflet_type_id],
                           params[:myrake][:leaflet_title],
                           params[:myrake][:leaflet_desc],
                           params[:myrake][:leaflet_url]) != false
        redirect_to myrake_path(@rake, heap_type: params[:myrake][:leaflet_type_id])
      else
        flash[:error] = @rake.leaflet_errors.full_messages.to_sentence
        redirect_to myrake_path(@rake, heap_type: params[:myrake][:leaflet_type_id])
      end
    elsif params[:commit] == "Add Recommendation Category"
      @rake.add_heap(params[:myrake][:leaflet_type_id])
      redirect_to myrake_path(@rake, heap_type: params[:myrake][:leaflet_type_id])
    elsif params[:commit] == "Move Leaflet"
      heapleaflet = HeapLeafletMap.where(heap_id: params[:myrake][:heap_id].to_i).find_by_leaflet_id(params[:myrake][:leaflet_id].to_i)
      # Check if there is an existing target heap
      target_rake = Myrake.where(user_id: current_user.id).find_by_name(params[:myrake][:name])
      target_rake_heaps = target_rake.heaps
      if target_rake_heaps.pluck(:leaflet_type_id).include? params[:myrake][:leaflet_type_id].to_i
        target_heap = target_rake_heaps.find_by_leaflet_type_id(params[:myrake][:leaflet_type_id].to_i)
        heapleaflet.update_attributes(heap_id: target_heap.id, leaflet_type_id: params[:myrake][:leaflet_type_id].to_i)
      else
        target_rake.add_heap(params[:myrake][:leaflet_type_id])
        target_heap = target_rake_heaps.find_by_leaflet_type_id(params[:myrake][:leaflet_type_id].to_i)
        heapleaflet.update_attributes(heap_id: target_heap.id, leaflet_type_id: params[:myrake][:leaflet_type_id].to_i)
      end
      redirect_to myrake_path(@rake, heap_type: Heap.find(params[:myrake][:heap_id].to_i).leaflet_type_id), :notice => "Leaflet moved."
    else
      @rake.filters.each do |f|
        f.destroy
      end
      filter_array = rake_params[:rake_filters].split(", ")
      filter_array.each do |f|
        @rake.add_filter(f, 1)
      end
      redirect_to myrake_path(@rake)
    end
  end

  def destroy
    rake = Myrake.find_by_id(params[:id])
    rake.destroy
    redirect_to myrakes_path, :notice => "Rake deleted."
  end

  def add_channel
    @rake = Myrake.find(params[:id])
    @rake.add_channel(Channel.find(params[:channel]))
    redirect_to myrake_path(@rake)
  end

  def remove_channel
    @rake = Myrake.find(params[:id])
    if !params[:channel].nil?
      @channel = Channel.find(params[:channel])
      @rake.remove_channel(@channel)
      respond_to do |format|
        format.html { redirect_to myrake_path(@rake.id) }
        format.js { render 'remove_channel' }
      end
    end
  end

  def toggle_channel_display
    @rake = Myrake.find(params[:id])
    @channel = Channel.find(params[:channel])
    display = params[:display] == "true"
    @rake.toggle_channel_display(@channel, display)
    respond_to do |format|
      format.html { redirect_to myrake_path(rake_id: @rake.id) }
    end
  end

  protected

  def rake_params
    params.require(:myrake).permit(:name, :master_rake_id, :user_id, :feed_leaflets, :rake_filters)
  end
end