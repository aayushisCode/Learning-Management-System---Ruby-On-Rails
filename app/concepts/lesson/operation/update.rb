
module Lesson::Operation
  class Update < Trailblazer::Operation
    step :check_admin
    step Model(Lesson, :find_by)
    step :update_lesson
    fail :handle_failure

    def check_admin(ctx, current_user:, **)
      unless current_user&.admin?
        ctx[:error] = {
          msg: "Only admin can update lessons",
          status: :forbidden
        }
        return false
      end

      true
    end

    def update_lesson(ctx, lesson_params:, **)
      if ctx[:model].update(lesson_params)
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] = if ctx[:model].nil?
        {
          msg: "Lesson not found",
          status: :not_found
        }
      else
        {
          msg: "Lesson update failed",
          status: :unprocessable_entity
        }
      end
    end
  end
end
