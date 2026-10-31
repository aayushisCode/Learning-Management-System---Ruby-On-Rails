class UserCourse < ApplicationRecord
  belongs_to :users
  belongs_to :course

  belongs_to :assigned_by, class_name: "User", optional: true

  has_many :lesson_progresses
  has_many :user_options
end
