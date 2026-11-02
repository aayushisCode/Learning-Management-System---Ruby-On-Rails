
module Lesson::Operation
  class Show < Trailblazer::Operation
    step :find_lesson
    fail :handle_failure

    def find_lesson(ctx, params:, **)
      ctx[:model] = Lesson.find_by(id: params[:id], course_id: params[:course_id])

      if ctx[:model]
        true
      else
        ctx[:errors] = [ "Lesson not found" ]
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] = "Unable to fetch lesson"
    end
  end
end
