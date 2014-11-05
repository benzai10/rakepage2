class HeapsController < ApplicationController

  def update
    redirect_to add_leaflet_heap_path(id: params[:id], 
                                      leaflet_id: params[:heap][:leaflet_id], 
                                      leaflet_type_id: params[:heap][:leaflet_type_id])
  end

  def add_leaflet
    @heap = Heap.find(params[:id])
    leaflet = Leaflet.find(params[:leaflet_id])
    begin
      @heap.add_leaflet(leaflet, params[:leaflet_type_id])
      respond_to do |format|
        format.html { redirect_to myrake_path(@heap.myrake_id) }
        format.js
      end
    rescue ActiveRecord::RecordNotUnique
      flash[:error] = "Leaflet is already in your heap!"
      redirect_to :back
    end
  end

  def remove_leaflet
    @heap = Heap.find(params[:id])
    @leaflet = Leaflet.find(params[:leaflet_id])
    @origin = params[:origin]
    begin
      @heap.remove_leaflet(@leaflet)
      respond_to do |format|
        format.html { redirect_to myrake_path(Myrake.find(@heap.myrake_id)), heap: "yes" }
        format.js {
          render 'remove_leaflet'
        }
      end 
    rescue ActiveRecord::RecordNotUnique
      flash[:error] = "Error while deleting. Try again."
      redirect_to :back
    end
  end

  def heap_params
    params.require(:heap).permit(:myrake_id)
  end
end
