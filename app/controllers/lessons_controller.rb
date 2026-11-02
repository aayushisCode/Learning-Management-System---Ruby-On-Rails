class LessonsController < ApplicationController
  def index
    result = Lesson::Operation::Index.call

    if result.success?
      render json: result[:models].as_json(
        only: [
          :id,
          :course_id,
          :title,
          :content_type,
          :position,
          :created_at,
          :updated_at
        ]
      ), status: :ok
    else
      render json: { error: result[:error] },
             status: :internal_server_error
    end
  end


  def create
    result = Lesson::Operation::Create.call(
      lesson_params: lesson_params
    )

    if result.success?
      render json: result[:model], status: :created
    else
      render json: {
        error: result[:error],
        errors: result[:errors]
      }, status: :unprocessable_entity
    end
  end

  private

  def lesson_params
    params.expect(
      lesson: [ :course_id, :title, :content_type, :position ]
    )
  end
end
