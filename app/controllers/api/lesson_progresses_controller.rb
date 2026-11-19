module Api
  # Lesson Progresses Controller
  class LessonProgressesController < ApplicationController
      def navigate_page
        result = run LessonProgressTracking::Operation::NavigatePage do |result|
          return render json: {
            page_number: result[:page_number],
            page: result[:page],
            lesson_completed: result[:lesson_completed] || false,
            message: result[:message]
          }, status: :ok
        end
        render_operation_error(result)
      end
  end
end
