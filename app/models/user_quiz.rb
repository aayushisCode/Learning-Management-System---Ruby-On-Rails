
class UserQuiz < ApplicationRecord
  belongs_to :user_course
  belongs_to :quiz

  has_many :user_options, dependent: :destroy

  validates :attempt_number,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            },
            uniqueness: {
              scope: [:user_course_id, :quiz_id]
            }

  validates :status,
            presence: true,
            inclusion: { in: %w[in_progress submitted] }

  validates :result,
            inclusion: { in: %w[pass fail] },
            allow_nil: true

  validates :score, :total_marks, :pass_marks,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :percentage,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 100
            },
            allow_nil: true

  validate :quiz_must_belong_to_assigned_course
  validate :result_requires_submitted_status

  private

  def quiz_must_belong_to_assigned_course
    return unless quiz && user_course
    return if quiz.course_id == user_course.course_id

    errors.add(:quiz, "must belong to the assigned course")
  end

  def result_requires_submitted_status
    return if result.blank? || status == "submitted"

    errors.add(:result, "can only be set after submission")
  end
end
