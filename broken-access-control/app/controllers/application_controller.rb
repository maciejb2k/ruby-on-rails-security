class ApplicationController < ActionController::Base
  include Pundit
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  allow_browser versions: :modern

  protect_from_forgery with: :exception
end
