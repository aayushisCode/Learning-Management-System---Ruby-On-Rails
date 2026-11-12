class CreateUserLessonProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :user_lesson_progresses do |t|
      t.references :user_course, null: false, foreign_key: true
      t.references :lesson_page, null: false, foreign_key: true

      t.string :status, null: false, default: "not_started"
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :user_lesson_progresses,
              [:user_course_id, :lesson_page_id],
              unique: true,
              name: "index_user_lesson_progresses_on_course_and_page"
  end
end