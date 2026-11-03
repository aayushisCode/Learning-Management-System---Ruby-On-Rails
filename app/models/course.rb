class Course < ApplicationRecord
  belongs_to :category

  has_many :lessons, dependent: :destroy
  has_many :user_courses, dependent: :destroy
  has_many :users, through: :user_courses

  has_many :quizzes, dependent: :restrict_with_error
  has_many :question_banks, dependent: :restrict_with_error

  before_validation :normalize_title

  validates :title,
            presence: true,
            uniqueness: {
              scope: :category_id,
              case_sensitive: false
            }

  validates :status,
            presence: true,
            inclusion: { in: %w[draft published archived] }

  private

  def normalize_title
    self.title = title&.strip
  end
end
