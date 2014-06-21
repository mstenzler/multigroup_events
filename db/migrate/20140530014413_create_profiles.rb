class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.integer :default_profile_view_id
      t.string :short_description
      t.text :long_description
      t.boolean :enable_personal, default: false
      t.boolean :enable_business, default: false
      t.boolean :enable_resume, default: false

      t.timestamps
    end

    add_index "profiles", ["user_id"], :name => "profile_user_id_opt"
  end
end
