
class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  # GET /questions
  def index
    result = run Question::Operation::Index,
                  with: { params: params } do |result|
      return render json: {
        data: result[:models].as_json(
          only: [
            :id, :category_id, :course_id, :quiz_id,
            :question_text, :question_type, :correct_option_id,
            :marks, :position, :status, :created_at, :updated_at
          ],
          include: {
            options: {
              only: [ :id, :option_text, :position ]
            }
          }
        )
      }, status: :ok
    end

    render_operation_error(result, default_status: :internal_server_error)
  end

  # GET /questions/:id
  def show
    result = run Question::Operation::Show,
                  with: { params: params } do |result|
      return render json: {
        data: result[:model].as_json(
          only: [
            :id, :category_id, :course_id, :quiz_id,
            :question_text, :question_type, :correct_option_id,
            :marks, :position, :status, :created_at, :updated_at
          ],
          include: {
            options: {
              only: [ :id, :option_text, :position ]
            }
          }
        )
      }, status: :ok
    end

    render_operation_error(result, default_status: :not_found)
  end

  # POST /questions
  def create
    result = run Question::Operation::Create,
                  with: { question_params: question_params } do |result|
      return render json: {
        data: result[:model].as_json(
          only: [
            :id, :category_id, :course_id, :quiz_id,
            :question_text, :question_type, :correct_option_id,
            :marks, :position, :status, :created_at, :updated_at
          ],
          include: {
            options: {
              only: [ :id, :option_text, :position ]
            }
          }
        )
      }, status: :created
    end

    render_operation_error(result)
  end

  # PATCH /questions/:id
  def update
    result = run Question::Operation::Update,
                  with: {
                    params: params,
                    question_params: question_params
                  } do |result|
      return render json: {
        data: result[:model].as_json(
          only: [
            :id, :category_id, :course_id, :quiz_id,
            :question_text, :question_type, :correct_option_id,
            :marks, :position, :status, :created_at, :updated_at
          ],
          include: {
            options: {
              only: [ :id, :option_text, :position ]
            }
          }
        )
      }, status: :ok
    end

    render_operation_error(result)
  end

  # DELETE /questions/:id
  def destroy
    result = run Question::Operation::Destroy,
                  with: { params: params } do |_result|
      return head :no_content
    end

    render_operation_error(result, default_status: :not_found)
  end

  private

  def require_admin!
    authorize!("admin")
  end

  def question_params
    raw = params.require(:question).permit(
      :category_id,
      :course_id,
      :quiz_id,
      :question_text,
      :question_type,
      :marks,
      :position,
      :status,
      :correct_option_position,
      options_attributes: [ :option_text, :position ]
    )

    raw.to_h.with_indifferent_access
  end
end
