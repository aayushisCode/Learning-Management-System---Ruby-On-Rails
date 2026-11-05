module Question::Operation
  class Update < Trailblazer::Operation
    step :find_question
    step :update_question
    fail :handle_failure

    def find_question(ctx, params:, **)
      ctx[:model] = Question.find_by(id: params[:id])

      unless ctx[:model]
        ctx[:error] = "Question not found"
        return false
      end

      true
    end

    def update_question(ctx, params:, **)
      attributes = permitted_attributes(params, :question)

      unless ctx[:model].update(attributes)
        ctx[:error] = ctx[:model].errors.full_messages
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= ctx[:model]&.errors&.full_messages || "Unable to update question"
      true
    end

    private

    def permitted_attributes(params, key)
      attributes = params[key] || {}
      attributes = attributes.to_unsafe_h if attributes.respond_to?(:to_unsafe_h)

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
