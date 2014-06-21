class CreateGeoContinents < ActiveRecord::Migration
  def change
    create_table :geo_continents do |t|
      t.string :continent_name, :limit => 25
      t.integer :rank

      t.timestamps
    end
  end
end
