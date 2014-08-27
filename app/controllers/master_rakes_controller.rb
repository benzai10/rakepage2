class MasterRakesController < ApplicationController

  def index
    @master_rakes = MasterRake.all
    session[:rake_class] = MasterRake
    @categories = Category.all
    if !params[:category_id].nil?
      @category = @categories.find(params[:category_id].to_i)
    end
    @new_master_rakes = @master_rakes.order(created_at: :desc).limit(13)
    @new_leaflets = Leaflet.where("id IN (?) AND leaflet_type_id <> 15",
                            MasterHeapLeafletMap.pluck(:leaflet_id)).order(created_at: :desc).limit(50)
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
    #@leaflet_types = CategoryLeafletTypeMap.where(category_id: @rake.category_id).pluck(:leaflet_type_id)
    #rake_ids = @rake.myrakes.pluck(:id)
    #@heaps = Heap.where("myrake_id IN (?)", rake_ids)
    #@heap_types = @heaps.pluck(:leaflet_type_id).uniq
    #params[:heap_type] ||= "News"

    #heap_ids = []
    #@rake.myrakes.each do |r|
    #  heap_ids << r.heaps.pluck(:id)
    #end
    #@heap_leaflets = Leaflet.where("id IN (?)", HeapLeafletMap.where("heap_id IN (?)", heap_ids.flatten).pluck(:leaflet_id).flatten).order("updated_at DESC").uniq
    #@heap_leaflets_maps = HeapLeafletMap.where("leaflet_id IN (?)", @heap_leaflets.map(&:id))
    @heaps = @rake.master_heaps
    @feed_collapse = params[:collapse] == "feed" ? "in" : ""
    @heap_collapse = params[:collapse].to_s.first(4) == "heap" ? "in" : ""
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
    if @master_rake.check_wikipedia_url(params[:master_rake][:wikipedia_url]) != false
      if @master_rake.save
        #redirect_to master_rake_path(@master_rake)
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
    if @master_rake.update_attributes(master_rake_params)
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
