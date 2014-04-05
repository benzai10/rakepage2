class AuthenticationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @authentications = current_user.authentications if current_user
  end

  def create
    auth = Authentication.from_omniauth(current_user, request.env["omniauth.auth"])
    flash[:notice] = "Authentication successful."
    p auth
    redirect_to authentications_url
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end

  def connect_facebook
    redirect_to '/auth/facebook'
  end

  def show
  end

end
