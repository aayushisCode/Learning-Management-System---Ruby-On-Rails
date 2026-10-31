class Lesson < ApplicationRecord
  belongs_to :course

  has_many :lesson_progresses
  has_many :quizzes

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }

  validates :position, uniqueness: { scope: :course_id }
end
