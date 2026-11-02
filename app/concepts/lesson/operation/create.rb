module Lesson::Operation
  class Create < Trailblazer::Operation
    step :build_lesson
    fail :handle_failure

    def build_lesson(ctx, lesson_params:, **)
      ctx[:model] = Lesson.new(lesson_params)

      if ctx[:model].save
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] = "Lesson creation failed"
    end
  end
end
