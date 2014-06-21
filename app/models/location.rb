class Location < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :geo_area
  belongs_to :owner, :class_name => "user", :foreign_key => "owner_user_id"
##  has_many :events                 

#	attr_accessible :name, :address, :geo_area, :geo_area_attributes,
#	                :privacy, :category_id, :is_private_residence

  accepts_nested_attributes_for :geo_area

  validates_presence_of :name, :address

  PRIVACY_OPTIONS = ['PUBLIC', 'PRIVATE']

  def formatted_address
  	 read_attribute(:formatted_address) ? read_attribute(:formatted_address) : build_formatted_address
  end

  private

  def build_formatted_address
  	ret =""
  	if address
  		ret << address
  	end
  	if geo_area
  		if geo_area.place_name
  			ret << ", #{geo_area.place_name}"
  		end
  		if st = geo_area.state_code || geo_area.state_code
  			ret << ", st"
  		end
  		if geo_area.zip
  			ret << " #{geo_area.zip}"
  		end
  		if geo_area.geo_country && geo_area.geo_country.country_code
  			ret << ", #{geo_area.geo_country.country_code}"
  		end
  	end
  	ret
  end

end
