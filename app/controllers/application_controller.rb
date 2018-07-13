class ApplicationController < ActionController::Base
  helper_method :omniauth_path

  private

    def omniauth_path(strategy, origin = '')
      "/#{ENV['RELATIVE_URL_ROOT'] || ''}/auth/#{strategy}"
    end

end
