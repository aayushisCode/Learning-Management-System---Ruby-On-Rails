class CreateUserLessonProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :user_lesson_progresses, id: :uuid do |t|
      t.references :user_course,
                   type: :uuid,
                   null: false,
                   foreign_key: true

      t.references :lesson,
                   type: :uuid,
                   null: false,
                   foreign_key: true

      t.string :status, null: false, default: "not_started"
      t.jsonb :metadata, null: false, default: {}

      t.datetime :started_at
      t.datetime :completed_at
      t.float :progress_percentage, null: false, default: 0.0

      t.timestamps
    end

    add_index :user_lesson_progresses,
              [:user_course_id, :lesson_id],
              unique: true,
              name: "index_user_lesson_progresses_on_course_and_lesson"

    add_index :user_lesson_progresses, :status

    add_check_constraint :user_lesson_progresses,
                         "status IN ('not_started', 'in_progress', 'completed')",
                         name: "user_lesson_progresses_valid_status"

    add_check_constraint :user_lesson_progresses,
                         "progress_percentage >= 0 AND progress_percentage <= 100",
                         name: "user_lesson_progresses_valid_percentage"
  end
end
