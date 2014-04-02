class HeapsController < ApplicationController

  def show
    @heap = Heap.find(params[:id])
  end

  def update
    @heap = Heap.find(params[:id])
    leaflet = Leaflet.find(params[:leaflet_id])
    if params[:heap_method] == "remove"
      begin
        @heap.remove_leaflet(leaflet)
        redirect_to rake_path(@heap.rake_id)
      rescue ActiveRecord::RecordNotUnique
        flash[:error] = "Error while deleting. Try again."
        redirect_to :back
      end
    else
      begin
        @heap.add_leaflet(leaflet)
        redirect_to rake_path(@heap.rake_id)
      rescue ActiveRecord::RecordNotUnique
        flash[:error] = "Leaflet is already in your heap!"
        redirect_to :back
      end
    end
  end

  def heap_params
    params.require(:heap).permit(:rake_id, :leaflet_ids)
  end
end
