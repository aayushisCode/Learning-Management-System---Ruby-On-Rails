
module Quiz::Operation
  class Show < ApplicationOperation
    step :set_quiz
    fail :handle_failure

    def set_quiz(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, Quiz).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :show?)
      ctx[:response_data] = {
        data: ctx[:model].as_json(
          only: [:id, :course_id, :lesson_id, :title, :description, :quiz_type, :pass_marks, :created_at, :updated_at],
          include: { questions: { only: [:id, :question_text, :question_type, :marks, :position, :status], include: { options: { only: [:id, :option_text, :position] } } } }
        )
      }
      ctx[:status] = :ok
      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Quiz not found",
        status: :not_found
      }
    end
  end
end
