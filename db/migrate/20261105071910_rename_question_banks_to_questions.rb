class RenameQuestionBanksToQuestions < ActiveRecord::Migration[8.1]
  def change
    rename_table :question_banks, :questions
  end
end
