class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :category_name, null: false
      t.text :description

      t.timestamps
    end

    add_index :categories, "LOWER(category_name)", unique: true,
          name: "index_categories_on_lower_category_name"
  end
end
