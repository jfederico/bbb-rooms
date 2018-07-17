Rails.application.config.middleware.use OmniAuth::Builder do
  if ENV['OMNIAUTH_BBBLTIBROKER_KEY'] && ENV['OMNIAUTH_BBBLTIBROKER_SECRET']
    omniauth_provider = 'bbbltibroker'
    omniauth_site =ENV['OMNIAUTH_BBBLTIBROKER_SITE'] || "http://localhost:3000"
    omniauth_root = "#{ENV['OMNIAUTH_BBBLTIBROKER_ROOT'] ? '/' + ENV['OMNIAUTH_BBBLTIBROKER_ROOT'] : ''}"
  end
  # Prepare settings
  path_prefix = "#{ENV['RELATIVE_URL_ROOT'] ? '/' + ENV['RELATIVE_URL_ROOT'] : ''}/auth"
  client_options = {
    site: omniauth_site || '',
    authorize_url: "#{omniauth_root || ''}/oauth/authorize",
    token_url: "#{omniauth_root || ''}/oauth/token",
    revoke_url: "#{omniauth_root || ''}/oauth/revoke"
  }
  options = { provider_ignores_state: true, path_prefix: path_prefix, omniauth_root: omniauth_root, client_options: client_options }

  # Initialize the provider
  provider omniauth_provider, ENV["OMNIAUTH_BBBLTIBROKER_KEY"], ENV["OMNIAUTH_BBBLTIBROKER_SECRET"], options if omniauth_provider
end
