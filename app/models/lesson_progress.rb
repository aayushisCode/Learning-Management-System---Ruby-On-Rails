class LessonProgress < ApplicationRecord
  belongs_to :user_course
  belongs_to :lesson

  validates :status,
            presence: true,
            inclusion: {
              in: %w[not_started in_progress completed]
            }

  validates :completed_pages,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  validates :total_pages,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  validates :progress_percentage,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 100
            }

  validates :lesson_id,
            uniqueness: { scope: :user_course_id }

  validate :lesson_must_belong_to_assigned_course
  validate :completed_pages_cannot_exceed_total

  private

  def lesson_must_belong_to_assigned_course
    return unless lesson && user_course
    return if lesson.course_id == user_course.course_id

    errors.add(:lesson, "must belong to the assigned course")
  end

  def completed_pages_cannot_exceed_total
    return if completed_pages.nil? || total_pages.nil?
    return if completed_pages <= total_pages

    errors.add(:completed_pages, "cannot exceed total pages")
  end
end
