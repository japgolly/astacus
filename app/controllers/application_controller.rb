class ApplicationController < ActionController::Base
  helper :all
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  # Set content type
  before_filter :set_content_type
  def set_content_type
    headers["Content-Type"]= "text/html; charset=UTF-8"
  end

  # User login related
  helper_method :cur_user, :cur_user_id, :logged_in?
  USER_ID_SESSION_KEY= :user_id
  def cur_user_id
    session[USER_ID_SESSION_KEY]
  end
  def cur_user
    return nil unless cur_user_id
    @cur_user||= (User.find(cur_user_id) rescue nil)
  end
  def logged_in?
    !cur_user_id.nil?
  end
end
