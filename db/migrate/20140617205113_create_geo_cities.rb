class CreateGeoCities < ActiveRecord::Migration
  def change
    create_table :geo_cities do |t|
      t.string :city_name,       :limit => 80
      t.string :short_city_name, :limit => 60
      t.integer :geo_region_id
      t.integer :geo_country_id

      t.timestamps
    end

    add_index "geo_cities", ["geo_country_id", "geo_region_id"], :name => "geo_cities_region_opt"
  end
end
