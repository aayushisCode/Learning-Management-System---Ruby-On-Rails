class AddRoleForeignKeyToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :role, foreign_key: true
  end
end
