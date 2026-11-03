class AddProgressTrackingToUserCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :user_courses, :progress_percentage,
               :decimal, precision: 5, scale: 2,
               null: false, default: 0

    add_column :user_courses, :completed_lessons,
               :integer, null: false, default: 0

    add_column :user_courses, :total_lessons,
               :integer, null: false, default: 0
  end
end
