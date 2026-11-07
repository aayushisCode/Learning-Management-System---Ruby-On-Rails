class Quiz < ApplicationRecord
  belongs_to :course
  belongs_to :lesson, optional: true

  has_many :questions, dependent: :restrict_with_error
  has_many :user_quizzes, dependent: :restrict_with_error

  validates :title, presence: true

  validates :quiz_type,
            presence: true,
            inclusion: { in: %w[lesson final] }

  validates :pass_marks,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 100
            }

  validate :lesson_must_match_quiz_type

  private

  def lesson_must_match_quiz_type
    if quiz_type == "lesson"
      if lesson.blank?
        errors.add(:lesson, "must be present for a lesson quiz")
      elsif lesson.course_id != course_id
        errors.add(:lesson, "must belong to the selected course")
      end

    elsif quiz_type == "final" && lesson.present?
      errors.add(:lesson, "must be absent for a final quiz")
    end
  end
end
