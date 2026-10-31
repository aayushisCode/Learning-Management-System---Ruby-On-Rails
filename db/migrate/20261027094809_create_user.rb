class CreateUser < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.references :role, null: false, foreign_key: true
      t.string :email, null: false
      t.string :password, null: false

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
