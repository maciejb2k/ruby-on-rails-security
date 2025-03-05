class DashboardController < ApplicationController
  before_action :require_login

  def index; end

  private

  def require_login
    return if session[:user_id]

    redirect_to login_path, alert: 'Musisz się zalogować.'
  end
end
