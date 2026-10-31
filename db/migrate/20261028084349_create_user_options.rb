class CreateUserOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :user_options do |t|
      t.references :user_course, foreign_key: true
      t.references :lesson_progress, foreign_key: true
      t.references :question, null: false, foreign_key: { to_table: :question_banks }
      t.references :option, null: false, foreign_key: true

      t.integer :attempt_number, null: false, default: 1

      t.timestamps
    end
    add_check_constraint :user_options,
      "(user_course_id IS NOT NULL AND lesson_progress_id IS NULL) OR " \
      "(user_course_id IS NULL AND lesson_progress_id IS NOT NULL)",
      name: "user_options_one_quiz_context"
  end
end
