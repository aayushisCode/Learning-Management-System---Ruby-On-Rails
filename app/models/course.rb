class Course < ApplicationRecord
  belongs_to :category

  has_many :lessons
  has_many :user_courses
  has_many :users, through: :user_courses

  has_many :quizzes
  has_many :question_banks
  validates :title, presence: true
  validates :status, inclusion: { in: %w[draft published archived] }
end
