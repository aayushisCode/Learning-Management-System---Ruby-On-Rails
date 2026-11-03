module Learning
  class QuizScorer
    def initialize(user_quiz)
      @user_quiz = user_quiz
      @quiz = user_quiz.quiz
    end

    def calculate
      questions = @quiz.question_banks

      total_marks = questions.sum(:marks)
      obtained_marks = 0

      questions.each do |question|
        answer = @user_quiz.user_options.find_by(
          question_id: question.id
        )

        next unless answer

        if answer.option_id == question.correct_option_id
          obtained_marks += question.marks
        end
      end

      percentage = if total_marks.zero?
                     0
      else
                     (obtained_marks.to_f / total_marks * 100).round(2)
      end

      {
        obtained_marks: obtained_marks,
        total_marks: total_marks,
        percentage: percentage,
        result: percentage >= @quiz.pass_marks ? "pass" : "fail"
      }
    end
  end
end
