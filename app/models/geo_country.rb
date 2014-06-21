class GeoCountry < ActiveRecord::Base
   has_many :users
   has_many :geo_areas
   has_many :geo_regions
   belongs_to :geo_continent

   @@country_list = nil #self.get_country_list(nil, true)
   @@country_list_geo_only = nil
   @@country_list_hash = nil

   validates_format_of :country_code,
                       :with => /\A[A-Z]{2}\z/i,
                       :message => "Invalid country code. Must be two letters"


  def self.get_country_list(*args)
    default_country=nil
    force_reload=true
    use_only_geo=false

    logger.debug("BEFORE: IN self.get_country_list!!!  force_reload = #{force_reload}. use_only_geo = #{use_only_geo}.")

    if ( (args.size >= 1) && (args[0].is_a? Hash) )
      params = args[0]
      default_country = params[:default_country] if params[:default_country]
      force_reload = params[:force_reload] if params[:force_reload]
      use_only_geo = params[:use_only_geo] if params[:use_only_geo]
      include_geo_areas = params[:include_geo_areas] if params[:include_geo_areas] 
    end

    logger.debug("AFTER: IN self.get_country_list!!!  force_reload = #{force_reload}. use_only_geo = #{use_only_geo}.")

    ret = nil
    country_list = use_only_geo ? @@country_list_geo_only : @@country_list
    logger.debug("GEO_COUNTRY::GET_COUNTRY_LIST - in method")
    if (force_reload || country_list.nil?)
      logger.debug("GEO_COUNTRY::GET_COUNTRY_LIST - getting from database")
      if use_only_geo
#        country_list = find(:all, :conditions=>["has_geo_data = ?", true], :order => [:rank_level, :rank, :country_name])
         country_list = where("has_geo_data = ?", true).order([:rank_level, :rank, :country_name])
      elsif include_geo_areas
        country_list = includes(:geo_regions).order([:rank_level, :rank, :country_name])
      else
        country_list = order([:rank_level, :rank, :country_name])
#        country_list = all.include(:geo_regions).order([:rank_level, :rank, :country_name])
#        country_list = find(:all, :order => [:rank_level, :rank, :country_name])
      end
    end

    if (default_country)
      ret = bring_default_to_top(country_list, default_country)
    else
      ret = country_list
    end
    ret
  end

  def self.get_country_list_hash
    @@country_list_hash = {}

    country_list = get_country_list
    country_list.each do |c|
      @@country_list_hash[c.id.to_s] = c
    end

    @@country_list_hash
  end

  private

  def self.bring_default_to_top(arr, default)
     new_arr = Array.new
     arr.each {
        |c|
        if c.country_code == default
           new_arr.unshift(c)
        else
           new_arr.push(c)
        end
     }
     new_arr
  end

end
