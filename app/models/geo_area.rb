class GeoArea < ActiveRecord::Base
  include Geokit::Geocoders
#  require 'num_helper'
#  extend NumHelper

  has_many :users
  has_many :locations
  belongs_to :geo_country

#  attr_accessible :geo_country_id, :state, :state_code, :place_name

  def self.create_geo_area(loc, geo_country, source)
    state = loc.state
    state_code = loc.state_code
#    if (state.length <= 2)
    if (state.blank? && !state_code.blank?)
      tmp_area = GeoArea.where("geo_country_id = ? and state_code = ?", geo_country.id, state_code).first
      state = tmp_area.state if tmp_area
    elsif (!state.blank? && state_code.blank?)
      tmp_area = GeoArea.where("geo_country_id = ? and state = ?", geo_country.id, state).first
      state_code = tmp_area.sate_code if tmp_area
    end #if

    create! do |geo_area|
      geo_area.geo_country_id = geo_country.id
      geo_area.place_name = loc.city
      geo_area.state = state
      geo_area.state_code = state_code
      geo_area.zip = loc.zip
      geo_area.latitude = loc.lat
      geo_area.longitude = loc.lng
      geo_area.source = source
    end

  end

  def self.get_or_create_geo_area(geo_country, zip)
    #If geo_country is a geo_country object do nothing, else check to make sure it is
    #an integer
    if (!(geo_country.is_a?  GeoCountry))
      if (geo_country.is_a? Integer)
        geo_country = GeoCountry.find(geo_country)
      else
        raise ArgumentError, "Invalid geo_country param: #{geo_country}", caller
      end
    end

#    geo_country = ( (geo_country.is_a? Integer) ? GeoCountry.find(geo_country) : geo_country)
    area = where("geo_country_id = ? and zip = ?", geo_country.id, zip).first

    unless area
      loc = GeonamesGeocoder.geocode "#{zip}, #{geo_country.country_code}"
#       loc = Geocoder.search("#{zip} #{geo_country.country_code}")
      if loc and loc.success
        area = create_geo_area(loc, geo_country, 'geonames')
      end #if
    end #unless
    area
  end

  def display
    subregion = self.state_code ? ", #{self.state_code}" : ''
    "#{self.place_name}#{subregion}"  
  end

end
