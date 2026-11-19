
module Question::Operation
  class Update < ApplicationOperation
    step :find_question
    step :update_question

    fail :handle_failure
    step :set_response

    def find_question(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, Question).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :update?)
      true
    end

    def set_response(ctx, **)
      question = ctx[:model]
      ctx[:response_data] = { data: question.as_json(
        only: [:id, :category_id, :course_id, :quiz_id, :question_text, :question_type,
          :correct_option_id, :marks, :position, :status, :created_at, :updated_at],
        include: { options: { only: [:id, :option_text, :position] } }
      ) }
      ctx[:status] = :ok
    end

    def update_question(ctx, params:, **)
      attributes = permitted_attributes(params, :question)

      if ctx[:model].update(attributes)
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] = if ctx[:model].nil?
        {
          msg: "Question not found",
          status: :not_found
        }
      else
        {
          msg: "Question update failed",
          status: :unprocessable_entity
        }
      end
    end

    private

    def permitted_attributes(params, key)
      attributes = params[key] || {}
      attributes = attributes.to_unsafe_h if attributes.respond_to?(:to_unsafe_h)
      attributes = attributes.with_indifferent_access

      attributes.slice(
        :category_id,
        :course_id,
        :quiz_id,
        :question_text,
        :question_type,
        :correct_option_id,
        :marks,
        :position,
        :status
      )
    end
  end
end
