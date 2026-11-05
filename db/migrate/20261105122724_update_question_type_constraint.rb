class UpdateQuestionTypeConstraint < ActiveRecord::Migration[8.1]
  def change
    remove_check_constraint :questions,
                            name: "questions_valid_type"

    add_check_constraint :questions,
                         "question_type IN ('mcq', 'boolean')",
                         name: "questions_valid_type"
  end
end
