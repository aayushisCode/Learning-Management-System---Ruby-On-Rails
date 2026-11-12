class LessonPage < ApplicationRecord
  belongs_to :lesson

  has_many :user_lesson_progresses, dependent: :restrict_with_error

  validates :title, presence: true

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: { scope: :lesson_id }

  validate :metadata_must_be_a_hash

  private

  def metadata_must_be_a_hash
    errors.add(:metadata, "must be an object") unless metadata.is_a?(Hash)
  end
end
