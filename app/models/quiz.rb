
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
            numericality: { greater_than_or_equal_to: 0 }

  validate :lesson_must_match_quiz_type

  def total_marks
    questions.sum(:marks)
  end

  private

  def lesson_must_match_quiz_type
    case quiz_type
    when "lesson"
      if lesson.blank?
        errors.add(:lesson, "must be present for a lesson quiz")
      elsif lesson.course_id != course_id
        errors.add(:lesson, "must belong to the selected course")
      end

    when "final"
      errors.add(:lesson, "must be absent for a final quiz") if lesson.present?
    end
  end
end
