class Category < ApplicationRecord
  has_many :courses, dependent: :restrict_with_error
  has_many :lessons, through: :courses
  has_many :lesson_pages, through: :lessons
  has_many :questions, dependent: :restrict_with_error

  validates :category_name,
            presence: true,
            uniqueness: { case_sensitive: false }
end
