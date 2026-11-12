
module Quiz::Operation
  class Create < Trailblazer::Operation
    step Model(Quiz, :new)
    step :build_quiz
    step :save_quiz
    fail :handle_failure

    def build_quiz(ctx, quiz_params:, **)
      ctx[:model].assign_attributes(
        permitted_attributes(quiz_params)
      )

      true
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
        msg: ctx[:errors]&.join(", ") || "Unable to create quiz",
        status: :unprocessable_entity
      }
    end

    private

    def permitted_attributes(quiz_params)
      quiz_params.to_h.slice(
        "course_id",
        "lesson_id",
        "title",
        "description",
        "quiz_type",
        "pass_marks"
      )
    end
  end
end
