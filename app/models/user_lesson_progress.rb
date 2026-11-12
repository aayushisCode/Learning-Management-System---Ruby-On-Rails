class UserLessonProgress < ApplicationRecord
  belongs_to :user_course
  belongs_to :lesson_progress

  validates :status,
            presence: true,
            inclusion: {
              in: %w[not_started in_progress completed]
            }

  validates :lesson_progress_id,
            uniqueness: { scope: :user_course_id }

  validate :page_belongs_to_assigned_course

  private

  def page_belongs_to_assigned_course
    return unless user_course && lesson_page

    unless user_course.course_id == lesson_page.lesson.course_id
      errors.add(:lesson_page, "does not belong to the assigned course")
    end
  end
end