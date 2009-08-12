class HomeController < ApplicationController
  def index
  end

  def login
    return redirect_to(root_url) unless request.xhr? and request.post?
    u,p = params[:username],params[:password]
    @user= User.find_by_username_and_password(u,p) rescue nil if u and p
    session[USER_ID_SESSION_KEY]= @user.id if @user
  end

  def logout
    session[USER_ID_SESSION_KEY]= nil
    if request.xhr?
      render(:update) {|page| page.reload}
    else
      redirect_to root_url
    end
  end
end
