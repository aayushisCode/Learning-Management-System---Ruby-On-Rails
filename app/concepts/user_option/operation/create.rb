module UserOption::Operation
  class Create < Trailblazer::Operation
    step :find_attempt
    step :validate_attempt
    step :find_question
    step :find_option
    step :save_answer
    fail :handle_failure

    def find_attempt(ctx, params:, current_user:, **)
      ctx[:user_quiz] = UserQuiz.joins(:user_course)
                                .find_by(
                                  id: params[:user_quiz_id],
                                  user_courses: { user_id: current_user.id }
                                )

      unless ctx[:user_quiz]
        ctx[:error] = "Quiz attempt not found"
        return false
      end

      true
    end

    def validate_attempt(ctx, **)
      unless ctx[:user_quiz].status == "in_progress"
        ctx[:error] = "Answers cannot be changed after quiz submission"
        return false
      end

      true
    end

    def find_question(ctx, params:, **)
      ctx[:question] = Question.find_by(id: params[:question_id])

      unless ctx[:question]
        ctx[:error] = "Question not found"
        return false
      end

      unless ctx[:question].quiz_id == ctx[:user_quiz].quiz_id
        ctx[:error] = "Question does not belong to this quiz"
        return false
      end

      true
    end

    def find_option(ctx, params:, **)
      ctx[:option] = Option.find_by(
        id: params[:option_id],
        question_id: ctx[:question].id
      )

      unless ctx[:option]
        ctx[:error] = "Selected option does not belong to this question"
        return false
      end

      true
    end

    def save_answer(ctx, **)
      ctx[:model] = UserOption.find_or_initialize_by(
        user_quiz_id: ctx[:user_quiz].id,
        question_id: ctx[:question].id
      )

      ctx[:model].option = ctx[:option]

      unless ctx[:model].save
        ctx[:error] = ctx[:model].errors.full_messages
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "Unable to save answer"
      true
    end
  end
end
