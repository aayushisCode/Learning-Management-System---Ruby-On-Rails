module Quizzes
  class ScoreCalculator
    def self.call(user_quiz:)
      quiz = user_quiz.quiz

      total_marks = quiz.questions.sum(:marks)

      score = user_quiz.user_options.sum do |user_option|
        question = user_option.question

        if question.correct_option_id == user_option.option_id
          question.marks
        else
          0
        end
      end

      result = score >= quiz.pass_marks ? "pass" : "fail"

      percentage =
        total_marks.zero? ? 0.0 :
        (score.to_f / total_marks * 100).round(2)

      {
        score: score,
        total_marks: total_marks,
        percentage: percentage,
        result: result
      }
    end
  end
end
