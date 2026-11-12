module Lesson::Operation
  class Create < Trailblazer::Operation
    step :check_admin
    step Model(Lesson, :new)
    step :build_lesson

    fail :handle_failure

    def check_admin(ctx, current_user:, **)
      unless current_user&.admin?
        ctx[:error] = {
          msg: "Only admin can create lessons",
          status: :forbidden
        }
        return false
      end

      true
    end

    def build_lesson(ctx, lesson_params:, **)
      ctx[:model].assign_attributes(lesson_params)

      if ctx[:model].save
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: ctx[:errors]&.join(", ") || "Lesson creation failed",
        status: :unprocessable_entity
      }
    end
  end
end
