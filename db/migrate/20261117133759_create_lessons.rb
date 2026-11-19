class CreateLessons < ActiveRecord::Migration[8.1]
  def change
    create_table :lessons, id: :uuid do |t|
      t.references :course, type: :uuid, null: false, foreign_key: true

      t.string :title, null: false
      t.string :content_type
      t.integer :position, null: false

      t.timestamps
    end

    add_index :lessons, [:course_id, :position], unique: true,  name: "index_lessons_on_course_and_position"
    add_check_constraint :lessons,
                         "position > 0",
                         name: "lessons_valid_position"
  end
end
