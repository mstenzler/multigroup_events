class CreateGeoRegions < ActiveRecord::Migration
  def change
    create_table :geo_regions do |t|
      t.string :region_name,       :limit => 35
      t.string :short_region_name, :limit => 25
      t.integer :geo_country_id

      t.timestamps
    end
    add_index "geo_regions", ["geo_country_id"], :name => "regions_country_code_opt"

  end
end
