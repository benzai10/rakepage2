class MasterRakesController < ApplicationController

  def index
    #session[:displayed_channels] = []
    @master_rakes = MasterRake.all
    session[:rake_class] = MasterRake
    #@rake = @master_rakes.first
    #if !params[:rake_id].nil?
    #  @rake = @master_rakes.where("id = ?", params[:rake_id].to_i).first
    #  @channels = @master_rakes.find_by_id(params[:rake_id].to_i).channels
    #  @feed_leaflets = @rake.feed_leaflets.page(params[:page]).per(10)
    #end
    #category_ids = MasterRake.all.pluck(:category_id).uniq
    #@categories = Category.where("id IN (?)", category_ids)
    @categories = Category.all
    if !params[:category_id].nil?
      @category = @categories.find(params[:category_id].to_i)
    end
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
        @heap_leaflets = Leaflet.where("id IN (?)", leaflet_ids)
      end
    end
    # all_rakes = @rake.rakes
    # if all_rakes.count > 0
    #   all_rakes.each do |r|

    #   end
    # end
    @feed_leaflets = @rake.feed_leaflets.order("published_at DESC").page(params[:page]).per(10)
    rake_ids = @rake.rakes.pluck(:id)
    @heaps = Heap.where("rake_id IN (?)", rake_ids)
    @heap_types = @heaps.pluck(:leaflet_type_id).uniq
    params[:heap_type] ||= "News"
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
    if @master_rake.save
      redirect_to master_rake_path(@master_rake)
    else
      flash[:error] = @master_rake.errors.full_messages
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
    ids = current_user.rakes.pluck(:master_rake_id)
    @master_rakes = MasterRake.where.not(id: ids)

    unless params[:master_rake].nil?
      params[:master_rake][:rakes].each do |master_rake_id,val|
        m_rake = MasterRake.find(master_rake_id)
        Rake.create!(name: m_rake.name, master_rake_id: master_rake_id, user_id: current_user.id)
      end
      redirect_to rakes_path
    end
  end


  protected

  def master_rake_params
    params.require(:master_rake).permit(:name, :rake, :category_id, :wikipedia_url, :created_by)
  end
end
