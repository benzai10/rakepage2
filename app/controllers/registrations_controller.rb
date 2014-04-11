class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    add_rake_master_rakes_path
  end
end

