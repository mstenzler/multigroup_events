class CreateAuthentications < ActiveRecord::Migration
  def self.up
    create_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :token
      t.string :token_secret
      t.string :refresh_token
      t.datetime :expires_at
      t.boolean :expires, default: true
      t.timestamps
    end
  end

  def self.down
    drop_table :authentications
  end
end
