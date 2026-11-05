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
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "Unable to fetch quizzes"
      true
    end
  end
end
