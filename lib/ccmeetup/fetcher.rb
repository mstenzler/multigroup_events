require "ccmeetup/fetcher/base"
require "ccmeetup/fetcher/topics"
require "ccmeetup/fetcher/cities"
require "ccmeetup/fetcher/members"
require "ccmeetup/fetcher/rsvps"
require "ccmeetup/fetcher/events"
require "ccmeetup/fetcher/groups"
require "ccmeetup/fetcher/comments"
require "ccmeetup/fetcher/photos"

module CCMeetup
  module Fetcher
    
    class << self
      # Return a fetcher for given type
      def for(type, auth)
        return  case type.to_sym
                when :topics
                  Topics.new(auth)
                when :cities      
                  Cities.new(auth)
                when :members     
                  Members.new(auth)
                when :rsvps       
                  Rsvps.new(auth)
                when :events      
                  Events.new(auth)
                when :groups      
                  Groups.new(auth)
                when :comments    
                  Comments.new(auth)
                when :photos
                  Photos.new(auth)
                end
      end 
    end
  end
end