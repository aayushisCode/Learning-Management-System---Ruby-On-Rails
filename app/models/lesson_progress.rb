class LessonProgress < ApplicationRecord
  belongs_to :user_course
  belongs_to :lesson

  has_many :user_options
end
