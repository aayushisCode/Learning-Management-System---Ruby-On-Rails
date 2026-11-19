
module UserOption::Operation
  class Create < ApplicationOperation
    step :find_attempt
    step :validate_attempt
    step :find_question
    step :find_option
    step :save_answer
    fail :handle_failure
    step :set_response

    def set_response(ctx, **)
      ctx[:response_data] = { message: "Answer saved successfully", data: ctx[:model] }
      ctx[:status] = :ok
    end

    def validate_attempt(ctx, user_quiz:, **)
      unless user_quiz.status == "in_progress"
        ctx[:error] = {
          msg: "Answers cannot be changed after quiz submission",
          status: :conflict
        }
        return false
      end

      true
    end

    def find_question(ctx, user_quiz:, params:, **)
      ctx[:question] = user_quiz.quiz.questions.find_by(id: params[:question_id])

      unless ctx[:question]
        ctx[:error] = {
          msg: "Question does not belong to this quiz",
          status: :not_found
        }
        return false
      end

      true
    end

    def find_option(ctx, params:, **)
      ctx[:option] = ctx[:question].options.find_by(id: params[:option_id])

      unless ctx[:option]
        ctx[:error] = {
          msg: "Selected option does not belong to this question",
          status: :unprocessable_entity
        }
        return false
      end

      true
    end

    def save_answer(ctx, user_quiz:, **)
      ctx[:model] = UserOption.find_or_initialize_by(
        user_quiz_id: user_quiz.id,
        question_id: ctx[:question].id
      )

      ctx[:model].option = ctx[:option]

      unless ctx[:model].save
        ctx[:errors] = ctx[:model].errors.full_messages
        ctx[:error] = {
          msg: "Unable to save answer",
          status: :unprocessable_entity
        }
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Unable to save answer",
        status: :unprocessable_entity
      }
    end
  end
end
    def find_attempt(ctx, params:, **)
      user_quiz = policy_scope_for(ctx, UserQuiz).find_by(id: params[:id])
      unless user_quiz
        ctx[:error] = { msg: "Quiz attempt not found", status: :not_found }
        return false
      end
      authorize_record(ctx, user_quiz, :answer?)
      answer = params.require(:answer).permit(:question_id, :option_id)
      ctx[:params] = answer
      ctx[:user_quiz] = user_quiz
    end
