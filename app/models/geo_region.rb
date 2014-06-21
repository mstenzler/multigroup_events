class GeoRegion < ActiveRecord::Base
 # attr_accessible :country_id, :region_name, :short_region_name

  belongs_to :geo_country

end
