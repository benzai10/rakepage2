class MasterRakesController < ApplicationController

  def index
    @master_rakes = MasterRake.all
    session[:rake_class] = MasterRake
    @categories = Category.all
    if !params[:category_id].nil?
      @category = @categories.find(params[:category_id].to_i)
    end
    @new_master_rakes = @master_rakes.order(created_at: :desc).limit(13)
    master_heap_ids = MasterHeap.where("leaflet_type_id <> 15").pluck(:id)
    @new_leaflets = MasterHeapLeafletMap.where("master_heap_id IN (?)", master_heap_ids).order(created_at: :desc).limit(50)
  end

  def show
    session[:displayed_channels] = []
    @master_rakes = MasterRake.all
    session[:rake_class] = MasterRake
    @rake = @master_rakes.find(params[:id].to_i)
    @channels = @rake.channels
    if user_signed_in?
      @custom_rake = @rake.existing_custom_rakes(current_user)
      if @custom_rake.count > 0
        @custom_heaps = @custom_rake.first.heaps
        heap_ids = @custom_heaps.pluck(:id)
        leaflet_ids = HeapLeafletMap.where("heap_id IN (?)", heap_ids).pluck(:leaflet_id)
        @heap_leaflets = Leaflet.where("id IN (?)", leaflet_ids).order("published_at DESC")
      end
    end
    @feed_leaflets = @rake.feed_leaflets(params[:refresh]).order("published_at DESC").page(params[:page]).per(50)
    @heaps = @rake.master_heaps
    @feed_collapse = params[:collapse] == "feed" ? "active" : ""
    @heap_collapse = params[:collapse].to_s.first(4) == "heap" ? "active" : ""
    if !@feed_collapse != "" || !@heap_collapse != ""
      @stats_collapse = "active"
    end
    @heap_id = params[:collapse].to_s.slice(5..-1)
  end

  def new
    @master_rake = MasterRake.new
    respond_to do |format|
      format.html
      format.json
    end
  end

  def create
    @master_rake = MasterRake.new(master_rake_params)
    if @master_rake.check_wikipedia_url(params[:master_rake][:wikipedia_url], params[:master_ra]) != false
      if @master_rake.save
        CategoryLeafletTypeMap.where(category_id: @master_rake.category_id).each do |c|
          MasterHeap.create(master_rake_id: @master_rake.id, leaflet_type_id: c.leaflet_type_id)

        end
        @rake = Myrake.new
        @rake.master_rake_id = @master_rake.id
        @rake.user_id = current_user.id
        @rake.name = @master_rake.name
        if @rake.save
          redirect_to myrake_path(@rake, refresh: "no")
        else
          flash[:error] = @rake.errors.full_messages
          redirect_to :back
        end
      else
        flash[:error] = @master_rake.errors.full_messages.to_sentence
        #redirect_to master_rakes_path(category_id: params[:master_rake][:category_id])
        redirect_to master_rakes_path
      end
    else
      flash[:error] = "Invalid Wikipedia URL"
      redirect_to :back
    end
  end

  def edit
    @master_rake = MasterRake.find(params[:id])
    respond_to do |format|
      format.html
      format.json
    end
  end

  def update
    @master_rake = MasterRake.find(params[:id])
    old_leaflet_types = Category.find(@master_rake.category_id).leaflet_types.pluck(:id)
    if @master_rake.update_attributes(master_rake_params)
      # if category changes, all leaflets need to be remapped
      CategoryLeafletTypeMap.where(category_id: params[:master_rake][:category_id].to_i).each do |c|
        MasterHeap.create(master_rake_id: @master_rake.id, leaflet_type_id: c.leaflet_type_id)
        rake_history = ""
        @master_rake.myrakes.each do |r|
          Heap.create(myrake_id: r.id, leaflet_type_id: c.leaflet_type_id)
          if rake_history.empty?
            History.create(user_id: r.user_id, 
                           master_rake_id: @master_rake.id,
                           rake_id: r.id,
                           history_code: "Master rake category changed")
            rake_history = "history is written"
          end
        end
      end
      # delete the not anymore valid master heaps and move their leaflets to 
      # master heap 'Uncategorized'
      new_leaflet_types = Category.find(params[:master_rake][:category_id].to_i).leaflet_types.pluck(:id)
      all_leaflet_types = old_leaflet_types + new_leaflet_types
      diff_leaflet_types = all_leaflet_types - new_leaflet_types
      uncategorized_master_heap = @master_rake.master_heaps.find_by_leaflet_type_id(1)
      if uncategorized_master_heap.nil?
        @master_rake.add_heap(1)
      end
      @master_rake.master_heaps.where("leaflet_type_id IN (?)", diff_leaflet_types).each do |h|
        MasterHeapLeafletMap.where(master_heap_id: h.id).each do |l|
          l.update_attributes(master_heap_id: uncategorized_master_heap.id)
        end
        h.destroy
        @master_rake.myrakes.each do |r|
          uncategorized_heap = r.heaps.find_by_leaflet_type_id(1)
          if uncategorized_heap.nil?
            r.add_heap(1)
          end
          r.heaps.where("leaflet_type_id IN (?)", diff_leaflet_types).each do |h|
            HeapLeafletMap.where(heap_id: h.id).each do |l|
              l.update_attributes(heap_id: uncategorized_heap.id)
            end
            h.destroy
          end
        end
      end
      redirect_to master_rake_path(@master_rake)
    else
      redirect_to :back
    end
  end

  def destroy
    master_rake = MasterRake.find_by_id(params[:id])
    master_rake.destroy
    redirect_to master_rakes_path, :notice => "Rake Deleted."
  end

  def toggle_channel_display
    @master_rake = MasterRake.find(params[:id])
    @channel = Channel.find(params[:channel])
    display = params[:display] == "true"
    @master_rake.toggle_channel_display(@channel, display)
    respond_to do |format|
      format.html { redirect_to master_rake_path(@master_rake) }

    end
  end

  def remove_channel
    @master_rake = MasterRake.find(params[:id])
    if !params[:channel].nil?
      @channel = Channel.find(params[:channel])
      @master_rake.remove_channel(@channel)
      respond_to do |format|
        format.html { redirect_to master_rake_path(@master_rake.id) }
        format.js { render 'remove_channel' }
      end
    end
  end


  def add_rake
    ids = current_user.myrakes.pluck(:master_rake_id)
    @master_rakes = MasterRake.where.not(id: ids)

    unless params[:master_rake].nil?
      params[:master_rake][:rakes].each do |master_rake_id,val|
        m_rake = MasterRake.find(master_rake_id)
        Rake.create!(name: m_rake.name, master_rake_id: master_rake_id, user_id: current_user.id)
      end
      redirect_to myrakes_path
    end
  end


  protected

  def master_rake_params
    params.require(:master_rake).permit(:name, :rake, :category_id, :wikipedia_url, :created_by)
  end
end
