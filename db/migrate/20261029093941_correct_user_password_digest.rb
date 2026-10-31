class CorrectUserPasswordDigest < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :password, :string if column_exists?(:users, :password)

    add_column :users, :password_digest, :string unless column_exists?(:users, :password_digest)
  end
end
