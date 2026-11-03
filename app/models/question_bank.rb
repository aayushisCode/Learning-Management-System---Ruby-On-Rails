class QuestionBank < ApplicationRecord
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
           foreign_key: :question_id

  validates :question_text, presence: true

  validates :question_type,
            presence: true,
            inclusion: { in: %w[mcq true_false] }

  validates :status,
            presence: true,
            inclusion: { in: %w[active inactive] }

  validates :marks,
            numericality: { greater_than: 0 }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  validate :quiz_must_match_course
  validate :correct_option_must_belong_to_question

  private

  def quiz_must_match_course
    return unless quiz && course
    return if quiz.course_id == course_id

    errors.add(:quiz, "must belong to the selected course")
  end

  def correct_option_must_belong_to_question
    return unless correct_option

    return if correct_option.question_id == id

    errors.add(:correct_option, "must belong to this question")
  end
end
