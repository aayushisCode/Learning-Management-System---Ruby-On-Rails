
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
    rescue StandardError => e
      Rails.logger.error("Lesson Index Error: #{e.full_message}")
      false
    end

    def handle_failure(ctx, **)
      ctx[:error] = {
        msg: "Unable to fetch lessons",
        status: :internal_server_error
      }
    end
  end
end
