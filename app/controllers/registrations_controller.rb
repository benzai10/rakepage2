class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    if resource.is_a?(User)
      master_rakes_path
    else
      super
    end
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end

