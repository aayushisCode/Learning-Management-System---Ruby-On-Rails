
module Lesson::Operation
  class Index < ApplicationOperation
    step :fetch_lessons
    fail :handle_failure
    step :set_response

    def fetch_lessons(ctx, params:, current_user:, **)
      pundit = Pundit::Context.new(user: current_user)
      pundit.authorize(Lesson, query: :index?, policy_class: nil)
      lessons = pundit.policy_scope(Lesson).includes(:lesson_pages)

      if params[:course_id].present?
        lessons = lessons.where(course_id: params[:course_id])
      end

      ctx[:models] = lessons.to_a
    rescue StandardError => e
      Rails.logger.error("Lesson Index Error: #{e.full_message}")
      false
    end

    def set_response(ctx, params:, **)
      models = ctx[:models]
      ctx[:response_data] = {
        course_id: params[:course_id],
        total_lessons: models.size,
        total_pages: models.sum { |lesson| lesson.lesson_pages.size },
        data: models.map do |lesson|
          pages = lesson.lesson_pages.sort_by(&:position)
          {
            id: lesson.id,
            course_id: lesson.course_id,
            title: lesson.title,
            content_type: lesson.content_type,
            position: lesson.position,
            total_pages: pages.size,
            lesson_pages: pages.map do |page|
              { id: page.id, title: page.title, topic: page.topic, position: page.position }
            end,
            created_at: lesson.created_at,
            updated_at: lesson.updated_at
          }
        end
      }
      ctx[:status] = :ok
    end

    def handle_failure(ctx, **)
      ctx[:error] = {
        msg: "Unable to fetch lessons",
        status: :internal_server_error
      }
    end
  end
end
