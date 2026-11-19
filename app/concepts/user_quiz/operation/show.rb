module UserQuiz::Operation
  class Show < ApplicationOperation
    step :find_attempt

    def find_attempt(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, UserQuiz)
        .includes(:quiz, user_options: [:question, :option])
        .find_by(id: params[:id])
      unless ctx[:model]
        ctx[:error] = { msg: "Quiz attempt not found", status: :not_found }
        return false
      end

      authorize_record(ctx, ctx[:model], :show?)
      attempt = ctx[:model]
      ctx[:response_data] = {
        id: attempt.id, quiz_id: attempt.quiz_id, user_course_id: attempt.user_course_id,
        attempt_number: attempt.attempt_number, status: attempt.status, result: attempt.result,
        score: attempt.score, total_marks: attempt.total_marks, percentage: attempt.percentage,
        started_at: attempt.started_at, submitted_at: attempt.submitted_at,
        answers: attempt.user_options.as_json(only: [:id, :question_id, :option_id])
      }
      ctx[:status] = :ok
    end
  end
end
