
module Question::Operation
  class Update < Trailblazer::Operation
    step Model(Question, :find_by)
    step :update_question

    fail :handle_failure

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
