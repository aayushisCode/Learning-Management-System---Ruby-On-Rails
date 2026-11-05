module Question::Operation
  class Index < Trailblazer::Operation
    step :fetch_questions
    fail :handle_failure

    def fetch_questions(ctx, params:, **)
      questions = Question.all

      questions = questions.where(quiz_id: params[:quiz_id]) if params[:quiz_id].present?
      questions = questions.where(course_id: params[:course_id]) if params[:course_id].present?
      questions = questions.where(category_id: params[:category_id]) if params[:category_id].present?

      ctx[:models] = questions.includes(:options).order(:position).to_a
      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "Unable to fetch questions"
      true
    end
  end
end
