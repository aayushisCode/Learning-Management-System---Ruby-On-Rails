module Lesson::Operation
  class Destroy < Trailblazer::Operation
    step :find_lesson
    step :destroy_lesson
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

    def destroy_lesson(ctx, **)
      if ctx[:model].destroy
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] = "Lesson deletion failed"
    end
  end
end
