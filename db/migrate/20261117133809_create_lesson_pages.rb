class CreateLessonPages < ActiveRecord::Migration[8.1]
  def change
    create_table :lesson_pages, id: :uuid do |t|
      t.references :lesson, type: :uuid, null: false, foreign_key: true

      t.string :title, null: false
      t.string :topic
      t.text :content

      t.jsonb :metadata, null: false, default: {}

      t.integer :position, null: false

      t.timestamps
    end

    add_index :lesson_pages, [:lesson_id, :position], unique: true, name: "index_lesson_page_num"
    add_check_constraint :lesson_pages,
                         "position > 0",
                         name: "lesson_pages_valid_position"
  end
end
