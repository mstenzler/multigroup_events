class GeoContinent < ActiveRecord::Base
#  attr_accessible :continent_name, :rank

  has_many :geo_countries
  
end
