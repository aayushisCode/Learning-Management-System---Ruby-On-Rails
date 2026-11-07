class AddUniqueIndexToUserOptions < ActiveRecord::Migration[8.1]
  def change
    add_index :user_options,
              [ :user_quiz_id, :question_id ],
              unique: true,
              name: "index_user_options_on_attempt_and_question"
  end
end
