
class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  # GET /questions
  def index
    result = Question::Operation::Index.call(params: params)

    if result.success?
      render json: result[:models].as_json(
        only: [
          :id, :category_id, :course_id, :quiz_id, :question_text,
          :question_type, :correct_option_id, :marks, :position,
          :status, :created_at, :updated_at
        ],
        include: {
          options: { only: [ :id, :option_text, :position ] }
        }
      ), status: :ok
    else
      render json: { error: result[:error] }, status: :internal_server_error
    end
  end

  # GET /questions/:id
  def show
    result = Question::Operation::Show.call(params: params)

    if result.success?
      render json: result[:model].as_json(
        only: [
          :id, :category_id, :course_id, :quiz_id, :question_text,
          :question_type, :correct_option_id, :marks, :position,
          :status, :created_at, :updated_at
        ],
        include: {
          options: { only: [ :id, :option_text, :position ] }
        }
      ), status: :ok
    else
      render json: { error: result[:error] }, status: :not_found
    end
  end

  # POST /questions
  # Body: { question: { ..., options_attributes: [...], correct_option_position: N } }
  def create
    result = Question::Operation::Create.call(
      question_params: question_params
    )

    if result.success?
      render json: result[:model].as_json(
        only: [
          :id, :category_id, :course_id, :quiz_id, :question_text,
          :question_type, :correct_option_id, :marks, :position,
          :status, :created_at, :updated_at
        ],
        include: {
          options: { only: [ :id, :option_text, :position ] }
        }
      ), status: :created
    else
      render json: {
        errors: result[:errors],
        error: result[:error]
      }, status: :unprocessable_entity
    end
  end

  # PATCH /questions/:id
  def update
    result = Question::Operation::Update.call(
      params: params,
      question_params: question_params
    )

    if result.success?
      render json: result[:model].as_json(
        only: [
          :id, :category_id, :course_id, :quiz_id, :question_text,
          :question_type, :correct_option_id, :marks, :position,
          :status, :created_at, :updated_at
        ],
        include: {
          options: { only: [ :id, :option_text, :position ] }
        }
      ), status: :ok
    else
      status = result[:error]&.include?("not found") ? :not_found : :unprocessable_entity

      render json: {
        errors: result[:errors],
        error: result[:error]
      }, status: status
    end
  end

  # DELETE /questions/:id
  def destroy
    result = Question::Operation::Destroy.call(params: params)

    if result.success?
      head :no_content
    else
      status = result[:error]&.include?("not found") ? :not_found : :unprocessable_entity

      render json: {
        error: result[:error],
        errors: result[:errors]
      }, status: status
    end
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
