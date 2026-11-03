class CreateUserQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :user_quizzes do |t|
      t.references :user_course, null: false, foreign_key: true
      t.references :quiz, null: false, foreign_key: true

      t.integer :attempt_number, null: false, default: 1

      t.decimal :score, precision: 8, scale: 2
      t.decimal :total_marks, precision: 8, scale: 2
      t.decimal :percentage, precision: 5, scale: 2

      t.string :status, null: false, default: "in_progress"
      t.string :result

      t.datetime :started_at
      t.datetime :submitted_at

      t.timestamps
    end

    add_index :user_quizzes,
              [ :user_course_id, :quiz_id, :attempt_number ],
              unique: true,
              name: "index_user_quizzes_on_course_quiz_attempt"
  end
end
