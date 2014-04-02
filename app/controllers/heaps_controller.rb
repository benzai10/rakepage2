class HeapsController < ApplicationController

  def edit
    @heap = Heap.find(params[:id])
    leaflet_id = params[:leaflet_id].to_i
    @heap.leaflet_ids << leaflet_id
    if @heap.save
      redirect_to rake_path(@heap.rake_id)
    else
      flash[:error] = @rake.errors.full_messages
      redirect_to :back
    end
  end

  def heap_params
    params.require(:heap).permit(:rake_id, :leaflet_ids)
  end
end
