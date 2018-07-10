class SessionsController < ApplicationController
  include ApplicationHelper
  before_action :session_setter

  def new
  end

  def create
    auth_hash = request.env['omniauth.auth']
    if !auth_hash
      logger.info "No auth_hash"
      redirect_to omniauth_failure_url
      return
    end
    if !auth_hash.uid
      logger.info "No uid"
      redirect_to omniauth_failure_url
      return
    end
    session[:uid] = auth_hash.uid
    redirect_to request.env['omniauth.origin']
  end

  def failure
    logger.info "******************************************************"
    logger.info "Omniauth Failure:"
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  def session_setter
    #reset_session
    #session[:expires_at] = 60.minutes.from_now
  end
end
