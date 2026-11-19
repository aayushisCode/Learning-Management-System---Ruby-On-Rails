class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :roles, "LOWER(name)", unique: true,
          name: "index_roles_on_lower_name"
  end
end
