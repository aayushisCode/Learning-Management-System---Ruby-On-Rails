
class CreateQuestionBank < ActiveRecord::Migration[8.1]
  def change
    create_table :question_banks do |t|
      t.references :category, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.references :quiz, null: false, foreign_key: true

      t.text :question_text, null: false
      t.string :question_type, null: false

      t.bigint :correct_option_id
      t.decimal :marks, precision: 6, scale: 2, null: false, default: 1
      t.integer :position, null: false

      t.timestamps
    end

    add_check_constraint :question_banks,
      "question_type IN ('mcq', 'true_false', 'msq')",
      name: "questions_valid_type"
  end
end
