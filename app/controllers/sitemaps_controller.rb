class SitemapsController < ApplicationController
  def index
    @master_rakes = MasterRake.all #we are generating url's for posts
    respond_to do |format|
     format.xml
    end
  end
end
