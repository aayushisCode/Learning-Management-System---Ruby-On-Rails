class CreateUserCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :user_courses, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :course, type: :uuid, null: false, foreign_key: true

      t.references :assigned_by,
                   type: :uuid, null: false,
                   foreign_key: { to_table: :users }

      t.string :status, null: false, default: "assigned"

      t.datetime :assigned_at
      t.date :due_date
      t.datetime :completed_at

      # Course progress tracking
      t.float :progress_percentage, null: false, default: 0.0

      t.integer :completed_lessons, null: false, default: 0
      t.integer :total_lessons, null: false, default: 0

      t.timestamps
    end

    add_index :user_courses, [:user_id, :course_id], unique: true
    add_index :user_courses, :status
    add_check_constraint :user_courses,
                         "status IN ('assigned', 'in_progress', 'completed')",
                         name: "user_courses_valid_status"
    add_check_constraint :user_courses,
                         "progress_percentage >= 0 AND progress_percentage <= 100",
                         name: "user_courses_valid_progress"
    add_check_constraint :user_courses,
                         "completed_lessons >= 0 AND total_lessons >= 0",
                         name: "user_courses_valid_lesson_counts"
    add_check_constraint :user_courses,
                         "completed_lessons <= total_lessons",
                         name: "user_courses_completed_lessons_limit"
  end
end
