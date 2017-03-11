class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  def after_sign_in_path_for(resource)
    rails_admin_path || request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end
end
