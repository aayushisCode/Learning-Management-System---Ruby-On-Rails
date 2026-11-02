class UserCourse < ApplicationRecord
  belongs_to :users
  belongs_to :course

  belongs_to :assigned_by, class_name: "User", optional: true

  has_many :lesson_progresses, dependent: :destroy
  has_many :user_options, dependent: :destroy

  validates :status, presence: true, inclusion: { in: %w[assigned in_progress completed ] }
  validates :user_id, uniqueness: { scope: :course_id }
end
