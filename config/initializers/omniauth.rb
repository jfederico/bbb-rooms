require File.expand_path('lib/omniauth/strategies/doorkeeper', Rails.root)

Rails.application.config.middleware.use OmniAuth::Builder do
  path_prefix = "/#{ENV['RELATIVE_URL_ROOT'] || ''}/auth"
  if ENV['OMNIAUTH_DOORKEEPER_KEY'] && ENV['OMNIAUTH_DOORKEEPER_SECRET']
    provider :doorkeeper, ENV["OMNIAUTH_DOORKEEPER_KEY"], ENV["OMNIAUTH_DOORKEEPER_SECRET"], {:provider_ignores_state => true, :path_prefix => path_prefix}
  end
end
