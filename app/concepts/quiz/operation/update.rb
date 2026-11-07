
module Quiz::Operation
  class Update < Trailblazer::Operation
    step Model(Quiz, :find_by)
    step :update_quiz
    fail :handle_failure

    def update_quiz(ctx, params:, **)
      attributes = permitted_attributes(params)

      unless ctx[:model].update(attributes)
        ctx[:errors] = ctx[:model].errors.full_messages
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= if ctx[:model].nil?
        {
          msg: "Quiz not found",
          status: :not_found
        }
      else
        {
          msg: "Unable to update quiz",
          status: :unprocessable_entity
        }
      end
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
