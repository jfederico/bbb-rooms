class ApplicationController < ActionController::Base
  helper_method :authenticated_user?
  helper_method :omniauth_path

  private

    def authenticated_user?
      logger.info ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      logger.info session[:uid]
      logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
      true if session[:uid]
    end

    def omniauth_path(strategy)
      #"/#{ENV['RELATIVE_URL_ROOT'] || ''}/auth/#{strategy}"
      "/#{ENV['RELATIVE_URL_ROOT'] || ''}/auth/#{strategy}"
    end

end
