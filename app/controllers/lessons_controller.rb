class LessonsController < ApplicationController
  def index
    result = Lesson::Operation::Index.call(params: params)

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

  # GET /lessons/:id
  def show
    result = Lesson::Operation::Show.call(params: params)

    if result.success?
      render json: result[:model].as_json(
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
      status = result[:errors]&.include?("Lesson not found") ?
                 :not_found : :internal_server_error

      render json: {
        error: result[:error],
        errors: result[:errors]
      }, status: status
    end
  end

  # PATCH /lessons/:id
  def update
    result = Lesson::Operation::Update.call(
      params: params,
      lesson_params: lesson_params
    )

    if result.success?
      render json: result[:model], status: :ok
    else
      status = result[:errors]&.include?("Lesson not found") ?
                 :not_found : :unprocessable_entity

      render json: {
        error: result[:error],
        errors: result[:errors]
      }, status: status
    end
  end

  # DELETE /lessons/:id
  def destroy
    result = Lesson::Operation::Destroy.call(params: params)

    if result.success?
      head :no_content
    else
      status = result[:errors]&.include?("Lesson not found") ?
                 :not_found : :unprocessable_entity

      render json: {
        error: result[:error],
        errors: result[:errors]
      }, status: status
    end
  end


  private

  def lesson_params
    params.expect(
      lesson: [ :course_id, :title, :content_type, :position ]
    )
  end
end
