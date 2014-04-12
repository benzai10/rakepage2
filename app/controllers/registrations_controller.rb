class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    if resource.is_a?(User)
      add_rake_master_rakes_path
    else
      super
    end
  end
end

