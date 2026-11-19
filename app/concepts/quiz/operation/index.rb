
class Quiz::Operation::Index < ApplicationOperation
  step :fetch_quizzes
  fail :handle_failure

  def fetch_quizzes(ctx, current_user:, params:, **)
    pundit = Pundit::Context.new(user: current_user)
    pundit.authorize(Quiz, query: :index?, policy_class: nil)
    quizzes = pundit.policy_scope(Quiz).includes(:course, :lesson)

    quizzes = quizzes.where(course_id: params[:course_id]) if params[:course_id].present?

    quizzes = quizzes.where(quiz_type: params[:quiz_type]) if params[:quiz_type].present?

    ctx[:models] = quizzes.order(:id).to_a
    ctx[:response_data] = {
      data: ctx[:models].as_json(only: [:id, :course_id, :lesson_id, :title, :description, :quiz_type, :pass_marks, :created_at, :updated_at])
    }
    ctx[:status] = :ok
    true
  rescue StandardError => e
    Rails.logger.error("Quiz Index Error: #{e.full_message}")

    ctx[:error] = {
      msg: "Unable to fetch quizzes",
      status: :internal_server_error
    }
    false
  end

  def handle_failure(ctx, **)
    ctx[:error] ||= {
      msg: "Unable to fetch quizzes",
      status: :internal_server_error
    }
  end
end
