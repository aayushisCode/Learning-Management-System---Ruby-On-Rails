
module Lesson::Operation
  class Create < Trailblazer::Operation
    step Model(Lesson, :new)
    step :build_lesson
    fail :handle_failure

    def build_lesson(ctx, lesson_params:, **)
      if ctx[:model].update(lesson_params)
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] = {
        msg: "Lesson creation failed",
        status: :unprocessable_entity
      }
    end
  end
end
