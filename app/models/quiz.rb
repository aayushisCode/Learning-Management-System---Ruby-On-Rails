class Quiz < ApplicationRecord
  belongs_to :courses
  belongs_to :lesson, optional: true

  has_many :question_banks
  validates :title, presence: true
  validates :quiz_type, inclusion: { in: %w[lesson final] }
  validates :pass_marks,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :lesson_must_match_course

  private

  def lesson_must_match_course
    return unless quiz_type == "lesson" && lesson.present?
    return if lesson.course_id == course_id

    errors.add(:lesson, "must belong to the selected course")
  end
end
