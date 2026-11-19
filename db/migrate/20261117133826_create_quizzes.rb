class CreateQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :quizzes, id: :uuid do |t|
      t.references :course, type: :uuid, null: false, foreign_key: true

      t.references :lesson, type: :uuid,
                            null: true,
                            foreign_key: true

      t.string :title, null: false
      t.text :description

      t.string :quiz_type, null: false

      t.float :pass_marks, null: false

      t.timestamps
    end

    add_check_constraint :quizzes,
                         "quiz_type IN ('final', 'lesson')",
                         name: "quizzes_valid_quiz_type"

    add_check_constraint :quizzes,
                         "(quiz_type = 'lesson' AND lesson_id IS NOT NULL) OR " \
                         "(quiz_type = 'final' AND lesson_id IS NULL)",
                         name: "quizzes_lesson_or_final_reference"
    add_check_constraint :quizzes,
                         "pass_marks >= 0",
                         name: "quizzes_valid_pass_marks"

    # One lesson quiz per lesson
    add_index :quizzes, :lesson_id,
            unique: true,
            where: "quiz_type = 'lesson'",
            name: "index_one_lesson_quiz_per_lesson"

    # One final quiz per course
    add_index :quizzes, :course_id,
            unique: true,
            where: "quiz_type = 'final'",
            name: "index_one_final_quiz_per_course"
  end
end
