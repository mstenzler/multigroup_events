class CreateGeoAreas < ActiveRecord::Migration
  def change
    create_table :geo_areas do |t|
      t.integer :geo_country_id
      t.string :place_name,     :limit => 200
      t.string :state,          :limit => 100
      t.string :state_code,     :limit => 20
      t.string :zip,            :limit => 10
      t.float :latitude
      t.float :longitude
      t.string :source,         :limit => 20

      t.timestamps
    end

    add_index "geo_areas", ["geo_country_id", "state"], :name => "geo_area_state_opt"
    add_index "geo_areas", ["geo_country_id", "state_code"], :name => "geo_area_state_code_opt"
    add_index "geo_areas", ["geo_country_id", "zip"], :name => "geo_area_zip_opt"
  end
end
