class CreateLessonPages < ActiveRecord::Migration[8.1]
  def change
    create_table :lesson_pages do |t|
      t.references :lesson, null: false, foreign_key: true
      t.string :title, null: false
      t.string :topic
      t.text :content
      t.json :metadata, null: false, default: {}
      t.integer :position, null: false

      t.timestamps
    end

    add_index :lesson_pages, [:lesson_id, :position], unique: true
  end
end
