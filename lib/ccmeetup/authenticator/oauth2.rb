module CCMeetup
  module Authenticator	

    # == CCMeetup::Authenticator::ApiKey
    # 
    # Implements Authentication scheme for the Meetup API using an api_key
    # 
    class Oauth2 < Base
      def initialize(options = {})
      	@authentication = options[:authentication]
        @access_token = options[:access_token]
        raise NotConfiguredError("Must pass :authentication or :access_token to CCMeetup::Authenticator::Oauth2.new") unless @api_key
      end
      
      #Add key=api_key to query string to authorize the request for the api_key
      def authorize_url(uri)
        token = @authentication.try(:get_fresh_token) || @access_token
      	add_to_query_string(uri, access_token: token)
      end
      
    end
  end
end