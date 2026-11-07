
module Quiz::Operation
  class Index < Trailblazer::Operation
    step :fetch_quizzes
    fail :handle_failure

    def fetch_quizzes(ctx, params:, **)
      quizzes = Quiz.all

      quizzes = quizzes.where(course_id: params[:course_id]) if params[:course_id].present?
      quizzes = quizzes.where(quiz_type: params[:quiz_type]) if params[:quiz_type].present?

      ctx[:models] = quizzes.includes(:course, :lesson).order(:id).to_a
      true
    rescue StandardError => e
      Rails.logger.error("Quiz Index Error: #{e.full_message}")
      false
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Unable to fetch quizzes",
        status: :internal_server_error
      }
    end
  end
end
