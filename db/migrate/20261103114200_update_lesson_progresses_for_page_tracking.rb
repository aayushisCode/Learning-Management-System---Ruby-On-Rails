class UpdateLessonProgressesForPageTracking < ActiveRecord::Migration[8.1]
  def change
    # Remove old quiz tracking fields
    remove_column :lesson_progresses, :quiz_attempts, :integer
    remove_column :lesson_progresses, :quiz_score, :decimal

    # Add page tracking fields
    add_column :lesson_progresses, :completed_pages,
               :integer, null: false, default: 0

    add_column :lesson_progresses, :total_pages,
               :integer, null: false, default: 0

    add_column :lesson_progresses, :progress_percentage,
               :decimal, precision: 5, scale: 2,
               null: false, default: 0
  end
end
