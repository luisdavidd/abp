class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, :with => :rescue404
  rescue_from ActionController::RoutingError, :with => :rescue404

  def rescue404
    render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found 
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :last_name, :codigo, :teacher])
  	devise_parameter_sanitizer.permit(:account_update,keys:[:current_password,:avatar]) 
  end

end
