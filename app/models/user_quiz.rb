class UserQuiz < ApplicationRecord
  belongs_to :user_course
  belongs_to :quiz

  has_many :user_options, dependent: :restrict_with_error

  validates :attempt_number,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            },
            uniqueness: {
              scope: [ :user_course_id, :quiz_id ]
            }

  validates :status,
            presence: true,
            inclusion: { in: %w[in_progress submitted] }

  validates :result,
            inclusion: { in: %w[pass fail] },
            allow_nil: true

  validate :quiz_must_belong_to_assigned_course

  private

  def quiz_must_belong_to_assigned_course
    return unless quiz && user_course
    return if quiz.course_id == user_course.course_id

    errors.add(:quiz, "must belong to the assigned course")
  end
end
