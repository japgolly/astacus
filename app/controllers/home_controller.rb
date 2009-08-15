class HomeController < ApplicationController
  def index
  end

  def login
    return redirect_to(root_url) unless request.xhr? and request.post?
    u,p = params[:username],params[:password]
    @user= User.find_by_username_and_password(u,p) rescue nil if u and p
    set_cur_user @user.id if @user
  end

  def logout
    set_cur_user nil
    if request.xhr?
      render(:update) {|page| page.reload}
    else
      redirect_to root_url
    end
  end

  private
    def set_cur_user(id)
      session[ApplicationHelper::USER_ID_SESSION_KEY]= id
    end
end
