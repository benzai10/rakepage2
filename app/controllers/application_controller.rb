class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  # Temporary Fix for "Can't verify CSRF token authenticity" in prod env
  protect_from_forgery with: :null_session,
      if: Proc.new { |c| c.request.format =~ %r{application/json} }

  before_filter :configure_permitted_parameters, if: :devise_controller?

  # around_filter :with_timezone

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      user_path(current_user)
    else
      super
    end
  end

  def after_sign_up_path_for(resource)
    if resource.is_a?(User)
      user_path(current_user)
    else
      super
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, 
                                                            :email,
                                                            :password,
                                                            :password_confirmation,
                                                            :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login,
                                                            :username,
                                                            :email,
                                                            :password,
                                                            :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username,
                                                            :email,
                                                            :password,
                                                            :password_confirmation,
                                                            :current_password) }
  end

  private

  def with_timezone
    timezone = Time.find_zone(cookies[:timezone])
    Time.use_zone(timezone) { yield }
  end

end
