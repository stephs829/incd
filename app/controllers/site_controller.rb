class SiteController < ApplicationController
  before_action :is_authenticated?, only: [ :index ]

  def index
    # @disable_nav = true
  end

  def new
    redirect_to root_url if current_user
  end
  
  def create
    if @user = User.find_by(email: params[:user][:email])
      @user.code = SecureRandom.urlsafe_base64
      @user.expires_at = Time.now + 1.day
      @user.save

      UserMailer.reset_email(@user, request).deliver
      
      flash.now[:notice] = "An email with instructions for " +
        "reseting your password has been sent to you."
      render :new
    else
      # attempt to authenticate
      @user = User.find_by(email: params[:user][:email])
  
      if @user && @user.authenticate(params[:user][:password])
        session[:user_id] = @user.id
        redirect_to root_url
      else
        flash.now[:error] = "Unable to sign you in. Please try again."
        render :new 
      end
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "You've logged out."
  end
end