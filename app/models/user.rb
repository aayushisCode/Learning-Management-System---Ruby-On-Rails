class User < ApplicationRecord
  has_secure_password
  belongs_to :role, optional: true

  has_many :user_courses
  has_many :courses, through: :user_courses

  has_many :assigned_user_courses, class_name: "UserCourse", foreign_key: :assigned_by_id

  before_validation :normalize_email
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }

  validates :address, presence: true

  validates :contact, presence: true, format: { with: /\A\+?[0-9()\-\s]{7,20}\z/ }
  private
  def normalize_email
    self.email = email.strip.downcase if email.present?
  end
end
