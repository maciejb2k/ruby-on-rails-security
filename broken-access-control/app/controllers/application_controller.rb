class ApplicationController < ActionController::Base
  include Pundit

  allow_browser versions: :modern

  protect_from_forgery with: :exception
end
