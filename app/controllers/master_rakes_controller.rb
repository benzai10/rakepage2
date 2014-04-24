class MasterRakesController < ApplicationController

  def index
    session[:displayed_channels] = []
    @master_rakes = MasterRake.all
    session[:rake_class] = MasterRake
    if params[:id].nil?
      @channels = @master_rakes.first.channels
    else
      @channels = @master_rakes.find_by_id(params[:id].to_i).channels
    end
  end

  def show
    @rake = MasterRake.find(params[:id])
    @channels = @rake.channels.where("channel_type <> 1")
    @feed_leaflets = Leaflet.where("channel_id IN (?)", 
                     @rake.channels_master_rakes.map{ |rc| (rc.display == true) ? rc.channel_id : nil}.compact).page(params[:page]).per(10)
    session[:rake_class] = MasterRake
    respond_to do |format|
      format.html
      format.json
    end
  end

  def new
    @master_rake = MasterRake.new
  end

  def create
    @master_rake = MasterRake.new(master_rake_params)
    if @master_rake.save
      redirect_to master_rakes_path
    else
      flash[:error] = @master_rake.errors.full_messages
      redirect_to :back
    end
  end

  def edit
    @master_rake = MasterRake.find(params[:id])
  end

  def update
    @master_rake = MasterRake.find(params[:id])
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
    params.require(:master_rake).permit(:name, :rake)
  end
end
