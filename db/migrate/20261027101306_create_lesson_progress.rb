class CreateLessonProgress < ActiveRecord::Migration[8.1]
  def change
    create_table :lesson_progresses do |t|
      t.references :user_course, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true

      t.string :status, null: false, default: "not_started"
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :quiz_attempts, null: false, default: 0
      t.decimal :quiz_score, precision: 6, scale: 2

      t.timestamps
    end

    add_index :lesson_progresses, [ :user_course_id, :lesson_id ], unique: true
  end
end
