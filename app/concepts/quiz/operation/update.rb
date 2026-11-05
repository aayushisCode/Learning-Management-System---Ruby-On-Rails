module Quiz::Operation
  class Update < Trailblazer::Operation
    step :find_quiz
    step :update_quiz
    fail :handle_failure

    def find_quiz(ctx, params:, **)
      ctx[:model] = Quiz.find_by(id: params[:id])

      unless ctx[:model]
        ctx[:error] = "Quiz not found"
        return false
      end

      true
    end

    def update_quiz(ctx, params:, **)
      attributes = permitted_attributes(params)

      unless ctx[:model].update(attributes)
        ctx[:error] = ctx[:model].errors.full_messages
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= ctx[:model]&.errors&.full_messages || "Unable to update quiz"
      true
    end

    private

    def permitted_attributes(params)
      attributes = params[:quiz] || {}
      attributes = attributes.to_unsafe_h if attributes.respond_to?(:to_unsafe_h)

      attributes.slice(
        :course_id,
        :lesson_id,
        :title,
        :description,
        :quiz_type,
        :pass_marks
      )
    end
  end
end
