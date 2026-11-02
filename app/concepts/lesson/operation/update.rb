module Lesson::Operation
  class Update < Trailblazer::Operation
    step :find_lesson
    step :update_lesson
    fail :handle_failure

    def find_lesson(ctx, params:, **)
      ctx[:model] = Lesson.find_by(id: params[:id])

      if ctx[:model]
        true
      else
        ctx[:errors] = [ "Lesson not found" ]
        false
      end
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
      ctx[:error] = "Lesson update failed"
    end
  end
end
