module OmniAuth
  module Strategies
    class Doorkeeper < OmniAuth::Strategies::OAuth2
      option :name, :doorkeeper
      option :path_prefix, "/#{ENV['RELATIVE_URL_ROOT'] || ''}/auth/doorkeeper"

      option :client_options, {
        site: ENV['OMNIAUTH_DOORKEEPER_URL'] || "http://localhost:3000",
        authorize_path: "/oauth/authorize",
      }

      uid do
        raw_info["id"]
      end

      info do
        {name: raw_info["name"]}
        {origin: raw_info["origin"]}
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/user.json').parsed
      end
    end
  end
end
