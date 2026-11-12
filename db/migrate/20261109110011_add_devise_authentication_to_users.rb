class AddDeviseAuthenticationToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :encrypted_password, :string, null: false, default: ""
    add_column :users, :jti, :string

    # Preserve existing BCrypt password hashes.
    execute <<-SQL
      UPDATE users
      SET encrypted_password = password_digest
      WHERE password_digest IS NOT NULL
        AND password_digest != ''
    SQL

    # Initialize JWT IDs for existing users.
    execute <<-SQL
      UPDATE users
      SET jti = lower(hex(randomblob(16)))
      WHERE jti IS NULL
    SQL

    change_column_default :users, :encrypted_password, nil
    change_column_null :users, :jti, false
    add_index :users, :jti, unique: true
  end

  def down
    remove_index :users, :jti
    remove_column :users, :jti
    remove_column :users, :encrypted_password
  end
end
