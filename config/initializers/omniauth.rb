Rails.application.config.middleware.use OmniAuth::Builder do
	provider :meetup, CONFIG[:meetup_key], CONFIG[:meetup_secret]
#	provider :facebook, CONFIG[:facebook_id], ENV[:facebook_secret]
#  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
#  provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET']
end
