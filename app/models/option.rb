class Option < ApplicationRecord
  belongs_to :question, class_name: "QuestionBank", foreign_key: :question_id

  has_many :correct_for_questions, class_name: "QuestionBank", foreign_key: :correct_option_id

  has_many :user_options
end
