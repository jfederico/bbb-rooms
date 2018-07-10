module OmniAuth
  module Strategies
    class Doorkeeper < OmniAuth::Strategies::OAuth2
      option :name, :doorkeeper

      option :client_options, {
        site: ENV['OMNIAUTH_DOORKEEPER_SITE'] || "http://localhost:3000",
        authorize_url: "#{'/' + ENV['OMNIAUTH_DOORKEEPER_ROOT'] || ''}/oauth/authorize"
      }

      uid do
        raw_info["id"]
      end

      info do
        {name: raw_info["name"]}
        {origin: raw_info["origin"]}
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/users.json').parsed
      end
    end
  end
end
