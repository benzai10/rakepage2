class PagesController < ApplicationController

  def landing
  end

  def terms_of_service
    render 'terms_of_service'
  end

  def privacy_policy
    render 'privacy_policy'
  end
end
