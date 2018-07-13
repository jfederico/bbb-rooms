class SessionsController < ApplicationController
  include ApplicationHelper

  def new
  end

  def create
    logger.info "****************************************************** A"
    logger.info params
    logger.info "Omniauth Create:"
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
    logger.info "All good"
    session[:uid] = auth_hash.uid
    logger.info session[:uid]
    logger.info request.env['omniauth.origin']
    #redirect_to request.env['omniauth.origin']
    #redirect_to lookup_path(session[:handler])
    logger.info cookies[:launch_params]
    logger.info JSON.parse(cookies[:launch_params]).to_query
    logger.info launch_url()
    query = JSON.parse(cookies[:launch_params]).to_query
    cookies.delete('launch_params')
    redirect_to "#{launch_url()}?handler=#{query}"
  end

  def failure
    logger.info "****************************************************** B"
    logger.info "Omniauth Failure:"
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

end
