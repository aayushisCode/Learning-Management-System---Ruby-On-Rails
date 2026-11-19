class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions, id: :uuid do |t|
      t.references :category, type: :uuid, null: false, foreign_key: true
      t.references :course, type: :uuid, null: false, foreign_key: true
      t.references :quiz, type: :uuid, null: false, foreign_key: true

      t.text :question_text, null: false
      t.string :question_type, null: false

      # UUID reference to options table
      t.uuid :correct_option_id

      t.float :marks, null: false

      t.integer :position, null: false
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :questions, [:quiz_id, :position], unique: true
    add_index :questions, :correct_option_id

    add_check_constraint :questions,
                         "question_type IN ('mcq', 'true_false')",
                         name: "questions_valid_type"

    add_check_constraint :questions,
                         "status IN ('active', 'inactive')",
                         name: "questions_valid_status"
    add_check_constraint :questions,
                         "marks > 0",
                         name: "questions_valid_marks"

    add_check_constraint :questions,
                         "position > 0",
                         name: "questions_valid_position"
  end
end
