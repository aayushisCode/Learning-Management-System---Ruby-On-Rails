class UserOption < ApplicationRecord
  belongs_to :user_quiz

  belongs_to :question,
             class_name: "QuestionBank",
             foreign_key: :question_id

  belongs_to :option

  validates :question_id,
            uniqueness: { scope: :user_quiz_id }

  validate :option_must_belong_to_question
  validate :question_must_belong_to_attempted_quiz

  private

  def option_must_belong_to_question
    return unless option && question
    return if option.question_id == question_id

    errors.add(:option, "does not belong to the selected question")
  end

  def question_must_belong_to_attempted_quiz
    return unless question && user_quiz
    return if question.quiz_id == user_quiz.quiz_id

    errors.add(:question, "does not belong to the attempted quiz")
  end
end
