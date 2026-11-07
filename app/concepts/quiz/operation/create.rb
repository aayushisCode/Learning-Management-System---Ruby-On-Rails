
module Quiz::Operation
  class Create < Trailblazer::Operation
    step Model(Quiz, :new)
    step :build_quiz
    step :save_quiz
    fail :handle_failure

    def build_quiz(ctx, params:, **)
      attributes = permitted_attributes(params)
      ctx[:model].assign_attributes(attributes)
    end

    def save_quiz(ctx, **)
      unless ctx[:model].save
        ctx[:errors] = ctx[:model].errors.full_messages
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Unable to create quiz",
        status: :unprocessable_entity
      }
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
