class MyrakesController < ApplicationController

  def index
    session[:rake_class] = Myrake
    if !user_signed_in?
      redirect_to master_rakes_path
      return
    end
    @rakes = Myrake.where("user_id = ?", current_user.id)
    if @rakes.empty?
      redirect_to master_rakes_path
      return
    end
    @new_master_rakes = MasterRake.newly_added
    heap_ids = []
    @rakes.each do |r|
      heap_ids << r.heaps.pluck(:id)
    end
    heap_ids = heap_ids.flatten
    @recommendations = HeapLeafletMap.where("heap_id IN (?)", heap_ids)
    @new_leaflets = @recommendations.order(created_at: :desc).limit(50)
    @overdue_leaflets = @recommendations.where("reminder_at < ?", Time.now).order(:reminder_at)
    @scheduled_leaflets = @recommendations.where("reminder_at > ?", Time.now).order(:reminder_at)
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
    if user_signed_in?
      if current_user.id == @rake.user_id
        history_changed_category = History.where(rake_id: @rake.id, history_code: "Master rake category changed").last
        if !history_changed_category.nil? 
          flash[:notice] = "The category of the master rake has changed.
                          Recommendations which couldn't matched are in 'Uncategorized'.
                          You can move your recommendations from there to new recommendation types!"
          history_changed_category.update_attributes(history_code: "Master rake category change notified")
        end
      end
    end
    @feed_leaflets = @rake.feed_leaflets("news", params[:refresh]).order("published_at DESC").page(params[:page]).per(50)
    @leaflet_types = CategoryLeafletTypeMap.where(category_id: @rake.master_rake.category_id).pluck(:leaflet_type_id)
    missing_leaflet_types = @leaflet_types - @rake.heaps.pluck(:leaflet_type_id)
    missing_leaflet_types.each do |mlt|
      @rake.add_heap(mlt)
    end
    if user_signed_in? && current_user.admin?
      @heaps = @rake.heaps
    else
      @leaflet_types.delete(15)
      @heaps = @rake.heaps.where.not(leaflet_type_id: 15)
    end
    @heap_ids = @heaps.pluck(:id)
    @leaflet_ids = HeapLeafletMap.where("heap_id IN (?)", @heap_ids).pluck(:leaflet_id)
    @heap_leaflets = Leaflet.where("id IN (?)", @leaflet_ids)
    #@rake_filter = @rake.filters.map{ |f| f.keyword }.join(",")
    @feed_collapse = params[:collapse] == "feed" ? "active" : ""
    @heap_collapse = params[:collapse].to_s.first(4) == "heap" ? "active" : ""
    @heap_id = params[:collapse].to_s.slice(5..-1)
    if @feed_collapse == "active" || @heap_collapse == "active"
      @stats_collapse = ""
    else
      @stats_collapse = "active"
    end
    parent_rakes = Leaflet.where("leaflet_type_id = 15 AND url ILIKE ?", "%master_rakes/" + @rake.master_rake_id.to_s).pluck(:author).map(&:to_i)
    @parent_master_rakes = MasterRake.where("id IN (?)", parent_rakes)
    @children_master_rakes = MasterRake.where("id IN (?)",
                                Leaflet.where("leaflet_type_id = 15 AND author IN (?)",
                                        @rake.master_rake_id.to_s).pluck(:url).map{| x| x.partition("master_rakes/").last.to_i })
    @sibling_master_rakes = MasterRake.where("id <> ? AND id IN (?)",
                               @rake.master_rake_id,
                               Leaflet.where("leaflet_type_id = 15 AND author IN (?)", 
                                       @parent_master_rakes.pluck(:id).map(&:to_s)).pluck(:url).map{| x| x.partition("master_rakes/").last.to_i })

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
          @heap_leaflets_maps = MasterHeapLeafletMap.where("master_heap_id IN (?)", master_rake.master_heaps.pluck(:id))
          @heap_leaflets_maps.each do |hl|
            leaflet = Leaflet.find(hl.leaflet_id)
            @rake.add_leaflet(leaflet, hl.master_heap.leaflet_type_id, leaflet.title, hl.leaflet_desc)
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
    if params[:commit] == "Update Recommendation"
      leaflet = Leaflet.find(params[:myrake][:leaflet_id])
      heap_leaflet = HeapLeafletMap.where("heap_id = ? AND leaflet_id = ?", 
                                          params[:myrake][:heap_id].to_i, 
                                          params[:myrake][:leaflet_id].to_i).first
      case params[:myrake][:reminder_at].to_i
      when 0
        reminder_at = nil
      when 1
        reminder_at = Time.now + 1.day
      when 2
        reminder_at = Time.now + 3.day
      when 3
        reminder_at = Time.now + 1.week
      when 4
        reminder_at = Time.now + 1.month
      else
        reminder_at = nil
      end
      heap_leaflet.update_attributes(leaflet_title: params[:myrake][:leaflet_title], leaflet_desc: params[:myrake][:leaflet_desc], reminder_at: reminder_at)
      leaflet.update_attributes(title: params[:myrake][:leaflet_title], content: params[:myrake][:leaflet_desc], url: params[:myrake][:leaflet_url])
      redirect_to myrake_path(@rake, collapse: params[:myrake][:collapse], anchor: "anchor_leaflet_" + params[:myrake][:leaflet_id])
    elsif params[:commit] == "Save Recommendation"
      leaflet = Leaflet.find(params[:myrake][:leaflet_id])
      case params[:myrake][:reminder_at].to_i
      when 0
        reminder_at = nil
      when 1
        reminder_at = Time.now + 1.day
      when 2
        reminder_at = Time.now + 3.day
      when 3
        reminder_at = Time.now + 1.week
      when 4
        reminder_at = Time.now + 1.month
      else
        reminder_at = nil
      end
      @rake.add_leaflet(leaflet, 
                        params[:myrake][:leaflet_type_id],
                        params[:myrake][:leaflet_title],
                        params[:myrake][:leaflet_desc],
                        reminder_at)
      if session[:rake_class] == MasterRake
        redirect_to master_rake_path(@rake.master_rake_id, collapse: params[:myrake][:collapse], anchor: "anchor_leaflet_" + params[:myrake][:leaflet_id])
      else
        redirect_to myrake_path(@rake, collapse: params[:myrake][:collapse], anchor: "anchor_leaflet_" + params[:myrake][:leaflet_id])
      end
    elsif params[:commit] == "Create Recommendation"
      if params[:myrake][:leaflet_title].empty? || params[:myrake][:leaflet_desc].empty?
        url_data = @rake.url_data(params[:myrake][:leaflet_url])
      end
      if params[:myrake][:leaflet_title].empty?
        title = url_data[:leaflet_title]
      else
        title = params[:myrake][:leaflet_title]
      end
      if title.empty?
        title = params[:myrake][:leaflet_url]
      end
      if params[:myrake][:leaflet_desc].empty?
        description = url_data[:leaflet_desc]
      else
        description = params[:myrake][:leaflet_desc]
      end
      if description.empty?
        description = ""
      end
      if params[:myrake][:leaflet_type_id].to_i == 15
        leaflet_author = @rake.master_rake_id.to_s
      end
      case params[:myrake][:reminder_at].to_i
      when 0
        reminder_at = nil
      when 1
        reminder_at = Time.now + 1.day
      when 2
        reminder_at = Time.now + 3.day
      when 3
        reminder_at = Time.now + 1.week
      when 4
        reminder_at = Time.now + 1.month
      else
        reminder_at = nil
      end
      if @rake.create_leaflet(params[:myrake][:leaflet_type_id],
                           title,
                           description,
                           params[:myrake][:leaflet_url],
                           leaflet_author,
                           reminder_at) != false
        redirect_to myrake_path(@rake, collapse: params[:myrake][:collapse])
      else
        flash[:error] = @rake.leaflet_errors.full_messages.to_sentence
        redirect_to myrake_path(@rake, heap_type: params[:myrake][:leaflet_type_id])
      end
    elsif params[:commit] == "Add Recommendation Category"
      @rake.add_heap(params[:myrake][:leaflet_type_id])
      redirect_to myrake_path(@rake, heap_type: params[:myrake][:leaflet_type_id])
    elsif params[:commit] == "Move Recommendation"
      heapleaflet = HeapLeafletMap.where(heap_id: params[:myrake][:heap_id].to_i).find_by_leaflet_id(params[:myrake][:leaflet_id].to_i)
      # Check if there is an existing target heap
      target_rake = Myrake.where(user_id: current_user.id).find_by_name(params[:myrake][:name])
      target_rake_heaps = target_rake.heaps
      if target_rake_heaps.pluck(:leaflet_type_id).include? params[:myrake][:leaflet_type_id].to_i
        target_heap = target_rake_heaps.find_by_leaflet_type_id(params[:myrake][:leaflet_type_id].to_i)
        heapleaflet.update_attributes(heap_id: target_heap.id, leaflet_type_id: params[:myrake][:leaflet_type_id].to_i)
        master_heap = MasterHeap.where(master_rake_id: target_rake.master_rake.id, leaflet_type_id: params[:myrake][:leaflet_type_id].to_i).first
        if !master_heap.nil?
          MasterHeapLeafletMap.create(master_heap_id: master_heap.id, leaflet_id: params[:myrake][:leaflet_id].to_i)
        end
      else
        target_rake.add_heap(params[:myrake][:leaflet_type_id])
        target_heap = target_rake_heaps.find_by_leaflet_type_id(params[:myrake][:leaflet_type_id].to_i)
        heapleaflet.update_attributes(heap_id: target_heap.id, leaflet_type_id: params[:myrake][:leaflet_type_id].to_i)
        master_heap = MasterHeap.where(master_rake_id: target_rake.master_rake.id, leaflet_type_id: params[:myrake][:leaflet_type_id].to_i).first
        if !master_heap.nil?
          MasterHeapLeafletMap.create(master_heap_id: master_heap.id, leaflet_id: params[:myrake][:leaflet_id].to_i)
        end
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

  def get_url_title
    respond_to do |format|
      format.html { render :nothing }
      format.js { "Hello" }
    end
  end

  protected

  def rake_params
    params.require(:myrake).permit(:name, :master_rake_id, :user_id, :feed_leaflets, :rake_filters)
  end
end
