class User < ApplicationRecord
  devise :database_authenticatable,
         :validatable,
         :registerable,
         :recoverable,
         :jwt_authenticatable,
         jwt_revocation_strategy: self
  include Devise::JWT::RevocationStrategies::JTIMatcher

  belongs_to :role, optional: true

  has_many :user_courses
  has_many :courses, through: :user_courses
  has_many :user_quizzes, through: :user_courses
  has_many :user_lesson_progresses, through: :user_courses

  has_many :assigned_user_courses, class_name: "UserCourse", foreign_key: :assigned_by_id

  before_validation :normalize_email
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }

  validates :address, presence: true

  validates :contact, presence: true, format: { with: /\A\+?[0-9()\-\s]{7,20}\z/ }
  # safe navigation operator &. prevents errors when a user has no role.
  def admin?
    role&.name&.casecmp?("admin") || false
  end

  def manager?
    role&.name&.casecmp?("manager") || false
  end

  def learner?
    role&.name&.casecmp?("learner") || false
  end

  private
  def normalize_email
    self.email = email.strip.downcase if email.present?
  end
end
