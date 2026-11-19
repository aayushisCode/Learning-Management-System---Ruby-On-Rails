
class Quiz::Operation::Update < ApplicationOperation
  step :update_quiz
  fail :handle_failure
  step :set_response

  def update_quiz(ctx, params:, **)
    model = policy_scope_for(ctx, Quiz).find_by(id: params[:id])
    return false unless model
    authorize_record(ctx, model, :update?)
    quiz_params = params.require(:quiz).permit(
      :course_id, :lesson_id, :title, :description, :quiz_type, :pass_marks
    )
    quiz_params[:course_id] ||= params[:course_id] if params[:course_id].present?
    unless model.update(quiz_params)
      ctx[:errors] = model.errors.full_messages
      ctx[:error] = {
        msg: "Unable to update quiz",
        status: :unprocessable_entity
      }
      return false
    end

    ctx[:model] = model
    true
  end

  def set_response(ctx, **)
    ctx[:response_data] = { data: ctx[:model] }
    ctx[:status] = :ok
  end

  def handle_failure(ctx, **)
    ctx[:error] ||= {
      msg: ctx[:errors]&.join(", ") || "Unable to update quiz",
      status: :unprocessable_entity
    }
  end
end
