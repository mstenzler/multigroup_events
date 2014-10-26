require 'rest-client'
class Authentication < ActiveRecord::Base
	belongs_to :user

  def provider_name
  	provider.titleize
  end

  def is_last_auth?
  	(!user.has_local_authentication? && (user.num_authentications <= 1)) ? true : false
  end

	def refresh_token_if_expired
	  if token_expired?
	  	case self.provider
	  	when "meetup"
	  		refresh_meetup_token
	  	when "facebook"
	  		refresh_facebook_token
	  	else
	  		raise "Invalid oauth2 provider in refresh_token"
	  	end

	    self.save
	    puts 'Saved'
	  end
	end

	def refresh_meetup_token
	    response    = RestClient.post "https://secure.meetup.com/oauth2/access", 
	    :grant_type => 'refresh_token', 
	    :refresh_token => self.refresh_token, 
	    :client_id => CONFIG[:meetup_key], 
	    :client_secret =>  CONFIG[:meetup_secret]
	    refreshhash = JSON.parse(response.body)
#	    token_will_change!
#	    token_expires_at_will_change!

	    self.token  = refreshhash['access_token']
	    self.refresh_token  = refreshhash['refresh_token']
	    self.token_expires_at = DateTime.now + refreshhash["expires_in"].to_i.seconds
	    logger.debug("new token = #{self.token}, token_expires_at = #{self.token_expires_at}")
	end

	def refresh_facebook_token

	end

	def token_expired?
	  expiry = self.token_expires_at ? Time.at(self.token_expires_at) : nil 
	  return true if expiry && expiry < Time.now # expired token, so we should quickly return
#	  token_expires_at = expiry
#	  save if changed?
	  false # token not expired. :D
	end
end
