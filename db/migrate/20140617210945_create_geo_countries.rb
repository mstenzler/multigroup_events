class CreateGeoCountries < ActiveRecord::Migration
  def change
    create_table :geo_countries do |t|
      t.string :country_code,       :limit => 2
      t.string :country_name,       :limit => 100
      t.boolean :has_geo_data
      t.string :short_country_name, :limit => 40
      t.integer :geo_continent_id
      t.integer :dial_code
      t.boolean :has_geo_regions
      t.integer :rank
      t.integer :rank_level

      t.timestamps
    end

    add_index "geo_countries", ["country_code"], :name => "country_code_opt", :unique => true
  end
end
