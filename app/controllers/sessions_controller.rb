class SessionsController < ApplicationController
  include ApplicationHelper

  def new
  end

  def create
    auth_hash = request.env['omniauth.auth']
    redirect_to omniauth_failure_url and return unless auth_hash && auth_hash.uid
    session[:uid] = auth_hash.uid
    query = JSON.parse(cookies[:launch_params]).to_query
    cookies.delete('launch_params')
    redirect_to "#{launch_url()}?#{query}"
  end

  def failure
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

end
