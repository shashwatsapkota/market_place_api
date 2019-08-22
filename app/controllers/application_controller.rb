class ApplicationController < ActionController::Base
  # prevent CSRF attacks by raising an exception
  # For APIs, you may want to use a null session instead
  protect_from_forgery with: :null_session

  include Authenticable
end
