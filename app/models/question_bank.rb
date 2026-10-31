class QuestionBank < ApplicationRecord
  belongs_to :category
  belongs_to :course
  belongs_to :quiz

  has_many :options, class_name: "Option", foreign_key: :question_id

  belongs_to :correct_option, class_name: "Option", foreign_key: :correct_option_id, optional: true

  has_many :user_options, foreign_key: :question_id
end
