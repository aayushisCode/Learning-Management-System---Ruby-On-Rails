class CreateQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :quizzes do |t|
      t.references :course, null: false, foreign_key: true
      t.references :lesson, null: true, foreign_key: true

      t.string :title, null: false
      t.text :description
      t.string :quiz_type, null: false
      t.integer :pass_marks, null: false

      t.timestamps
    end

    add_check_constraint :quizzes, "quiz_type IN ('final', 'lesson')", name: "quizzes_valid_quize_type"

    add_check_constraint :quizzes, "(quiz_type = 'lesson' AND lesson_id IS NOT NULL) OR " \
                                  "(quiz_type = 'final' AND lesson_id IS NULL)",
                                  name: "quizzes_lesson_or_final_reference"
  end
end
