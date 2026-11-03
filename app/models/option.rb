class Option < ApplicationRecord
  belongs_to :question,
             class_name: "QuestionBank",
             foreign_key: :question_id,
             inverse_of: :options

  has_many :correct_for_questions,
           class_name: "QuestionBank",
           foreign_key: :correct_option_id

  has_many :user_options,
           dependent: :restrict_with_error

  validates :option_text, presence: true

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  validates :position,
            uniqueness: { scope: :question_id }
end
