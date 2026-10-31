class UserOption < ApplicationRecord
  belongs_to :user_course, optional: true
  belongs_to :lesson_progress, optional: true

  belongs_to :question, class_name: "QuestionBank", foreign_key: :question_id

  belongs_to :option
end
