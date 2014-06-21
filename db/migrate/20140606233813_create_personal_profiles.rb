class CreatePersonalProfiles < ActiveRecord::Migration
  def change
    create_table :personal_profiles do |t|
      t.integer :user_id
      t.text :about
      t.text :looking_for
      t.string :privacy_type, :limit => 32
      t.string :age_display_type, :limit => 32
      t.integer :height_inches, :default => 0
      t.string  :height_display_type, :limit => 32
      t.integer :min_height_inches
      t.integer :max_height_inches
      t.integer :wanted_genders_mask
      t.integer :min_age
      t.integer :max_age

      t.timestamps
    end

    add_index :personal_profiles, [:height_inches], :name => "personal_profile_height_opt"
    add_index :personal_profiles, [:user_id], :name => "personal_profile_opt"

  end
end
