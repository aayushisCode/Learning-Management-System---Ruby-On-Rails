# class UserCourse < ApplicationRecord
#   belongs_to :user
#   belongs_to :course

#   belongs_to :assigned_by, class_name: "User", optional: true

#   has_many :lesson_progresses, dependent: :destroy
#   has_many :user_options, dependent: :destroy

#   validates :status, presence: true, inclusion: { in: %w[assigned in_progress completed ] }
#   validates :user_id, uniqueness: { scope: :course_id }
# end


class UserCourse < ApplicationRecord
  belongs_to :user
  belongs_to :course

  belongs_to :assigned_by,
             class_name: "User",
             optional: true

  has_many :lesson_progresses, dependent: :destroy
  has_many :user_quizzes, dependent: :destroy

  validates :status,
            presence: true,
            inclusion: { in: %w[assigned in_progress completed] }

  validates :user_id, uniqueness: { scope: :course_id }

  validates :progress_percentage,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  validates :completed_lessons,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :total_lessons,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :completed_lessons_cannot_exceed_total

  private

  def completed_lessons_cannot_exceed_total
    return if completed_lessons.nil? || total_lessons.nil?
    return if completed_lessons <= total_lessons

    errors.add(:completed_lessons, "cannot exceed total lessons")
  end
end
