module OmniAuth
  module Strategies
    class Doorkeeper < OmniAuth::Strategies::OAuth2
      option :name, :doorkeeper

      option :client_options, {
        site: ENV['OMNIAUTH_DOORKEEPER_SITE'] || "http://localhost:3000",
        authorize_url: "#{ENV['OMNIAUTH_DOORKEEPER_ROOT'] ? '/' + ENV['OMNIAUTH_DOORKEEPER_ROOT'] : ''}/oauth/authorize",
        token_url: "#{ENV['OMNIAUTH_DOORKEEPER_ROOT'] ? '/' + ENV['OMNIAUTH_DOORKEEPER_ROOT'] : ''}/oauth/token",
        revoke_url: "#{ENV['OMNIAUTH_DOORKEEPER_ROOT'] ? '/' + ENV['OMNIAUTH_DOORKEEPER_ROOT'] : ''}/oauth/revoke",
      }

      uid do
        raw_info["uid"]
      end

      info do
        {
          full_name: raw_info["full_name"],
          first_name: raw_info["first_name"],
          last_name: raw_info["last_name"]
        }
      end

      def raw_info
        @raw_info ||= access_token.get("#{ENV['OMNIAUTH_DOORKEEPER_ROOT'] ? '/' + ENV['OMNIAUTH_DOORKEEPER_ROOT'] : ''}/api/v1/user.json").parsed
      end

    end
  end
end
