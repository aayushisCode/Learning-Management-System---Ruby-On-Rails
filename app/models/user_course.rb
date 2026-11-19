
class UserCourse < ApplicationRecord
  belongs_to :user
  belongs_to :course

  belongs_to :assigned_by,
             class_name: "User"
  belongs_to :current_lesson,
             class_name: "Lesson",
             optional: true

  has_many :user_quizzes, dependent: :destroy
  has_many :user_lesson_progresses, dependent: :destroy

  # has_many :lesson_pages, through: :user_lesson_progresses

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
  validate :assigned_by_must_be_admin
  validate :current_resume_position_must_be_valid

  def save_resume_position(lesson:, page_number:)
    self.current_lesson = lesson
    self.current_page_number = page_number
    save!
  end

  def resume_position
    lesson = current_lesson
    page_number = current_page_number
    pages = lesson&.lesson_pages&.order(:position)&.to_a || []
    page = pages[page_number - 1] if page_number.is_a?(Integer) && page_number.positive?

    return resume_position_payload(lesson, page_number, page) if page && lesson.course_id == course_id

    first_lesson = course.lessons.includes(:lesson_pages).order(:position).first
    first_page = first_lesson&.lesson_pages&.first
    return nil unless first_lesson && first_page

    resume_position_payload(first_lesson, 1, first_page)
  end

  private

  def completed_lessons_cannot_exceed_total
    return if completed_lessons.nil? || total_lessons.nil?
    return if completed_lessons <= total_lessons

    errors.add(:completed_lessons, "cannot exceed total lessons")
  end

  def assigned_by_must_be_admin
  return if assigned_by&.admin?

  errors.add(:assigned_by, "must be an admin")
  end

  def current_resume_position_must_be_valid
    if current_lesson_id.nil? && current_page_number.nil?
      return
    elsif current_lesson_id.nil? || current_page_number.nil?
      errors.add(:current_page_number, "and current lesson must both be present")
      return
    end

    unless current_lesson&.course_id == course_id
      errors.add(:current_lesson, "must belong to the assigned course")
      return
    end

    unless current_page_number.is_a?(Integer) &&
           current_page_number.positive? &&
           current_lesson.lesson_pages.order(:position)
                        .offset(current_page_number - 1)
                        .exists?
      errors.add(:current_page_number, "must identify a page in the current lesson")
    end
  end

  def resume_position_payload(lesson, page_number, page)
    {
      lesson_id: lesson.id,
      lesson_position: lesson.position,
      page_id: page.id,
      page_number: page_number,
      page_position: page.position
    }
  end
end
