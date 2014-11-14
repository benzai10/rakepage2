class PagesController < ApplicationController

  def landing
    if user_signed_in?
      redirect_to user_path(current_user)
      return
    end
  end

  def terms_of_service
    render 'terms_of_service'
  end

  def privacy_policy
    render 'privacy_policy'
  end
end
