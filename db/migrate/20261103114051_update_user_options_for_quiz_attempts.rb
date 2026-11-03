class UpdateUserOptionsForQuizAttempts < ActiveRecord::Migration[8.1]
  def change
    # Remove the old constraint
    remove_check_constraint :user_options,
      name: "user_options_one_quiz_context"

    # Remove old quiz context references
    remove_reference :user_options, :user_course, foreign_key: true
    remove_reference :user_options, :lesson_progress, foreign_key: true

    # Remove attempt number because user_quizzes now stores it
    remove_column :user_options, :attempt_number, :integer

    # Connect selected answers to individual quiz attempts
    add_reference :user_options, :user_quiz,
      null: false,
      foreign_key: true

    # One answer per question per attempt
    add_index :user_options,
      [ :user_quiz_id, :question_id ],
      unique: true,
      name: "index_user_options_on_quiz_and_question"
  end
end
