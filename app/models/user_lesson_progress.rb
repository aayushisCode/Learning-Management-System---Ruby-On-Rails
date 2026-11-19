class UserLessonProgress < ApplicationRecord
  belongs_to :user_course
  belongs_to :lesson

  before_validation :initialize_metadata, on: :create

  validates :status,
            presence: true,
            inclusion: {
              in: %w[not_started in_progress completed]
            }

  validates :lesson_id,
            uniqueness: { scope: :user_course_id }

  validates :progress_percentage,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 100
            }

  validate :metadata_must_be_a_hash
  validate :lesson_belongs_to_assigned_course

  private

  def initialize_metadata
    self.metadata ||= {}
    return unless metadata.is_a?(Hash) && lesson

    self.metadata["pages"] ||= {}

    lesson.lesson_pages.each do |page|
      self.metadata["pages"][page.id.to_s] ||= {
        "completed" => false
      }
    end
  end

  def metadata_must_be_a_hash
    errors.add(:metadata, "must be an object") unless metadata.is_a?(Hash)
  end

  def lesson_belongs_to_assigned_course
    return unless user_course && lesson

    unless user_course.course_id == lesson.course_id
      errors.add(:lesson, "does not belong to the assigned course")
    end
  end

end
