class CreateUserCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :user_courses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.references :assigned_by, null: true, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "assigned"
      t.datetime :assigned_at
      t.date :due_date
      t.datetime :completed_at

      t.integer :final_quiz_attempts, null: false, default: 0
      t.decimal :final_quiz_score, precision: 6, scale: 2

      t.timestamps
    end
    add_index :user_courses, [ :user_id, :course_id ], unique: true
  end
end
