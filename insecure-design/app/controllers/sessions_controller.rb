class SessionsController < ApplicationController
  before_action :is_authenticated, only: %i[new create]

  def new; end

  # http://localhost:3000/login?redirect_to=http://localhost:3000/phishing-login
  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to params[:redirect_to] || dashboard_path
    else
      flash[:alert] = 'Nieprawidłowy e-mail lub hasło'
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: 'Wylogowano.'
  end

  private

  def is_authenticated
    redirect_to dashboard_path if session[:user_id]
  end
end
