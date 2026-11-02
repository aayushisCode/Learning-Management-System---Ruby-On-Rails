module Lesson::Operation
  class Index < Trailblazer::Operation
    step :fetch_lessons
    fail :handle_failure

    def fetch_lessons(ctx, params: {}, **)
      lessons = Lesson.all

      if params[:course_id].present?
        lessons = lessons.where(course_id: params[:course_id])
      end

      ctx[:models] = lessons.to_a
      true
    end

    def handle_failure(ctx, **)
      ctx[:error] = "Unable to fetch lessons"
    end
  end
end
