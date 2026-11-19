class Lesson < ApplicationRecord
  belongs_to :course

  has_many :quizzes, dependent: :restrict_with_error

  has_many :lesson_pages,
           -> { order(:position) },
           dependent: :destroy

  has_many :user_lesson_progresses, dependent: :destroy

  accepts_nested_attributes_for :lesson_pages,
                                allow_destroy: true

  validates :title, presence: true

  validates :position,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  validates :position, uniqueness: { scope: :course_id }
end
