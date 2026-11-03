class FinalizeQuestionAndCourseTracking < ActiveRecord::Migration[8.1]
  def change
    # Questions can be activated or deactivated.
    add_column :question_banks, :status,
               :string,
               null: false,
               default: "active"

    add_check_constraint :question_banks,
                         "status IN ('active', 'inactive')",
                         name: "questions_valid_status"

    # Quiz attempts are now maintained in user_quizzes.
    remove_column :user_courses,
                  :final_quiz_attempts,
                  :integer,
                  default: 0,
                  null: false

    remove_column :user_courses,
                  :final_quiz_score,
                  :decimal,
                  precision: 6,
                  scale: 2
  end
end
