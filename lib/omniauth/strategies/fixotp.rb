require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Fixotp < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'identify'.freeze

      option :name, 'fixotp'

      option :client_options,
             site: 'https://fix.network/',
             authorize_url: 'oauth/authorize',
             token_url: 'oauth/token'

      option :authorize_options, %i[scope permissions]

      uid { raw_info['id'] }

      info do
        {
            name: raw_info['phone_number'],
            phone_number: raw_info['phone_number'],
            email: raw_info['verified'] ? raw_info['email'] : nil,
        }
      end

      extra do
        {
            'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('fix_identities/me').parsed
      end

      def callback_url
        options[:callback_url] || (full_host + script_name + callback_path)
      end

      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |option|
            params[option] = request.params[option.to_s] if request.params[option.to_s]
          end

          params[:scope] ||= DEFAULT_SCOPE
        end
      end
    end
  end
end
