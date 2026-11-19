class CreateUserQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :user_quizzes, id: :uuid do |t|
      t.references :user_course,
                   type: :uuid,
                   null: false,
                   foreign_key: true

      t.references :quiz,
                   type: :uuid,
                   null: false,
                   foreign_key: true

      t.integer :attempt_number, null: false, default: 1

      t.float :score
      t.float :total_marks
      t.float :pass_marks
      t.float :percentage

      t.string :status, null: false, default: "in_progress"
      t.string :result

      t.datetime :started_at
      t.datetime :submitted_at

      t.timestamps
    end

    add_index :user_quizzes,
              [:user_course_id, :quiz_id, :attempt_number],
              unique: true,
              name: "index_user_quizzes_on_assignment_quiz_attempt"

    add_check_constraint :user_quizzes,
                         "attempt_number > 0",
                         name: "user_quizzes_valid_attempt_number"

    add_check_constraint :user_quizzes,
                         "status IN ('in_progress', 'submitted')",
                         name: "user_quizzes_valid_status"

    add_check_constraint :user_quizzes,
                         "result IS NULL OR result IN ('pass', 'fail')",
                         name: "user_quizzes_valid_result"

    add_check_constraint :user_quizzes,
                         "score IS NULL OR score >= 0",
                         name: "user_quizzes_valid_score"

    add_check_constraint :user_quizzes,
                         "total_marks IS NULL OR total_marks >= 0",
                         name: "user_quizzes_valid_total_marks"

    add_check_constraint :user_quizzes,
                         "percentage IS NULL OR (percentage >= 0 AND percentage <= 100)",
                         name: "user_quizzes_valid_percentage"

    add_check_constraint :user_quizzes,
                     "status = 'submitted' OR result IS NULL",
                     name: "user_quizzes_result_requires_submission"
  end
end
