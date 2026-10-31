
class FixUserPasswordColumns < ActiveRecord::Migration[8.1]
  def change
    if column_exists?(:users, :password)
      remove_column :users, :password, :string
    end

    unless column_exists?(:users, :password_digest)
      add_column :users, :password_digest, :string, null: false
    end
  end
end
