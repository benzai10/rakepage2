class HeapsController < ApplicationController

  def show
    @heap = Heap.find(params[:id])
  end

  def update
    redirect_to add_leaflet_heap_path(id: params[:id], 
                                      leaflet_id: params[:heap][:leaflet_id], 
                                      leaflet_type_id: params[:heap][:leaflet_type_id])
  end

  def add_leaflet
    #@heap = Heap.find(params[:id])
    #leaflet = Leaflet.find(params[:leaflet_id])
    @heap = Heap.find(params[:id])
    leaflet = Leaflet.find(params[:leaflet_id])
    begin
      @heap.add_leaflet(leaflet, params[:leaflet_type_id])
      respond_to do |format|
        format.html { redirect_to rake_path(@heap.rake_id) }
        format.js   #{ render 'heaps/add_leaflet.js.erb' }
      end
    rescue ActiveRecord::RecordNotUnique
      flash[:error] = "Leaflet is already in your heap!"
      redirect_to :back
    end
  end

  def remove_leaflet
    @heap = Heap.find(params[:id])
    @leaflet = Leaflet.find(params[:leaflet_id])
    begin
      @heap.remove_leaflet(@leaflet)
      respond_to do |format|
        format.html { redirect_to rake_path(Rake.find(@heap.rake_id)), heap: "yes" }
        format.js { render 'remove_leaflet'}
      end 
    rescue ActiveRecord::RecordNotUnique
      flash[:error] = "Error while deleting. Try again."
      redirect_to :back
    end
  end

  def heap_params
    params.require(:heap).permit(:rake_id)
  end
end
