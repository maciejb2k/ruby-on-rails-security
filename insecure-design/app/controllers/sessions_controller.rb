class SessionsController < ApplicationController
  rate_limit to: 5, within: 1.minute, with: -> { redirect_to rate_limited_path }, only: %i[create]

  before_action :authenticated?, only: %i[new create]

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      session[:user_email] = user.email
      redirect_to params[:redirect_to] || dashboard_path
    else
      flash[:alert] = 'Invalid email or password.'
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    session[:user_email] = nil
    redirect_to login_path, notice: 'Logged out successfully.'
  end

  private

  def authenticated?
    redirect_to dashboard_path if session[:user_id]
  end
end
