class AuthenticationsController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user
      @authentications = current_user.authentications
      current_user.import_fb unless @authentications.find_by(provider: "facebook").nil?
      respond_to do |format|
        format.html
        format.js   #{ render 'heaps/add_leaflet.js.erb' }
      end
    end
  end

  def create
    auth = Authentication.from_omniauth(current_user, request.env["omniauth.auth"])
    flash[:notice] = ["Authentication successful."]
    p auth
    redirect_to authentications_url
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = ["Successfully destroyed authentication."]
    redirect_to authentications_url
  end

  def connect_facebook
    redirect_to '/auth/facebook'
  end

  def connect_twitter
    redirect_to '/auth/twitter'
  end

end
