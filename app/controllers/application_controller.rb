class ApplicationController < ActionController::Base
  helper :all
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_filter :set_content_type
  def set_content_type
    headers["Content-Type"]= "text/html; charset=UTF-8"
  end
end
