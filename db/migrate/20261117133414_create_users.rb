class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.references :role, type: :uuid, null: false, foreign_key: true

      t.string :email, null: false
      t.string :name, null: false
      t.text :address, null: false
      t.string :contact, null: false
      t.string :encrypted_password, null: false, default: ""

      # Devise Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      # Devise JWT
      t.string :jti, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :jti, unique: true
  end
end
