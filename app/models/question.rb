class Question < ApplicationRecord
  belongs_to :category
  belongs_to :course
  belongs_to :quiz

  has_many :options,
           class_name: "Option",
           foreign_key: :question_id,
           dependent: :restrict_with_error

  belongs_to :correct_option,
             class_name: "Option",
             foreign_key: :correct_option_id,
             optional: true

  has_many :user_options,
           foreign_key: :question_id,
           dependent: :restrict_with_error

  validates :question_text, presence: true

  validates :question_type,
            presence: true,
            inclusion: { in: %w[mcq boolean] }

  validates :marks,
            numericality: { greater_than: 0 }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: { scope: :quiz_id }

  validate :correct_option_belongs_to_question
  validate :course_and_category_match_quiz

  private

  def correct_option_belongs_to_question
    return if correct_option_id.blank?
    return if correct_option&.question == self

    errors.add(:correct_option, "must belong to this question")
  end

  def course_and_category_match_quiz
    return unless quiz && course && category

    unless quiz.course_id == course_id
      errors.add(:course, "must match the quiz course")
    end

    unless course.category_id == category_id
      errors.add(:category, "must match the course category")
    end
  end
end
