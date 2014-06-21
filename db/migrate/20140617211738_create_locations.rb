class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.integer :user_id
      t.string :name,                 :limit => 70
      t.string :address
      t.string :formatted_address
      t.integer :geo_area_id
      t.string :privacy,              :limit => 24
      t.integer :category_id
      t.boolean :is_private_residence
      t.string :state,                :limit => 24
      t.string :editable_by,          :limit => 24
      t.integer :owner_user_id
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
