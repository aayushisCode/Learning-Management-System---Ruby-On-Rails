class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses, id: :uuid do |t|
      t.references :category, type: :uuid, null: false, foreign_key: true

      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "draft"

      t.timestamps
    end

     add_index :courses,
              "category_id, LOWER(title)",
              unique: true,
              name: "index_courses_on_category_and_lower_title"

    add_index :courses, :status
    add_check_constraint :courses,
                         "status IN ('draft', 'published', 'archived')",
                         name: "courses_valid_status"
  end
end
