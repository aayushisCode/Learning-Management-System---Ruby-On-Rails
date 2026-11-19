
module Question::Operation
  class Show < ApplicationOperation
    step :find_question

    fail :handle_failure

    def find_question(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, Question).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :show?)
      ctx[:response_data] = { data: ctx[:model].as_json(
        only: [:id, :category_id, :course_id, :quiz_id, :question_text, :question_type,
          :correct_option_id, :marks, :position, :status, :created_at, :updated_at],
        include: { options: { only: [:id, :option_text, :position] } }
      ) }
      ctx[:status] = :ok
      true
    end

    def handle_failure(ctx, **)
      ctx[:error] = {
        msg: "Question not found",
        status: :not_found
      }
    end
  end
end
