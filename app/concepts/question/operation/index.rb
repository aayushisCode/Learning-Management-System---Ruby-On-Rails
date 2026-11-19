
module Question::Operation
  class Index < ApplicationOperation
    step :fetch_questions

    fail :handle_failure

    def fetch_questions(ctx, params:, current_user:, **)
      pundit = Pundit::Context.new(user: current_user)
      pundit.authorize(Question, query: :index?, policy_class: nil)
      questions = pundit.policy_scope(Question)

      questions = questions.where(quiz_id: params[:quiz_id]) if params[:quiz_id].present?
      questions = questions.where(course_id: params[:course_id]) if params[:course_id].present?
      questions = questions.where(category_id: params[:category_id]) if params[:category_id].present?

      ctx[:models] = questions.includes(:options).order(:position).to_a
      ctx[:response_data] = { data: serialized_questions(ctx[:models]) }
      ctx[:status] = :ok
    rescue StandardError => e
      Rails.logger.error("Question Index Error: #{e.full_message}")
      false
    end

    def serialized_questions(models)
      models.as_json(
        only: [:id, :category_id, :course_id, :quiz_id, :question_text, :question_type,
          :correct_option_id, :marks, :position, :status, :created_at, :updated_at],
        include: { options: { only: [:id, :option_text, :position] } }
      )
    end

    def handle_failure(ctx, **)
      ctx[:error] = {
        msg: "Unable to fetch questions",
        status: :internal_server_error
      }
    end
  end
end
