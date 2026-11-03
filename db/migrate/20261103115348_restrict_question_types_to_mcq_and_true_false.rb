class RestrictQuestionTypesToMcqAndTrueFalse < ActiveRecord::Migration[8.1]
  def change
    remove_check_constraint :question_banks,
                            name: "questions_valid_type"

    add_check_constraint :question_banks,
                         "question_type IN ('mcq', 'true_false')",
                         name: "questions_valid_type"
  end
end
