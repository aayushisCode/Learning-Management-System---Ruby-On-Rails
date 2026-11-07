
class LessonsController < ApplicationController
  def index
    result = run Lesson::Operation::Index,
                  with: { params: params } do |result|
      return render json: {
        data: result[:models].as_json(
          only: [
            :id, :course_id, :title, :content_type,
            :position, :created_at, :updated_at
          ]
        )
      }, status: :ok
    end

    render_operation_error(result, default_status: :internal_server_error)
  end

  def create
    result = run Lesson::Operation::Create,
                  with: { lesson_params: lesson_params } do |result|
      return render json: { data: result[:model] }, status: :created
    end

    render_operation_error(result)
  end

  # GET /lessons/:id
  def show
    result = run Lesson::Operation::Show,
                  with: { params: params } do |result|
      return render json: {
        data: result[:model].as_json(
          only: [
            :id, :course_id, :title, :content_type,
            :position, :created_at, :updated_at
          ]
        )
      }, status: :ok
    end

    render_operation_error(result, default_status: :not_found)
  end

  # PATCH /lessons/:id
  def update
    result = run Lesson::Operation::Update,
                  with: {
                    params: params,
                    lesson_params: lesson_params
                  } do |result|
      return render json: { data: result[:model] }, status: :ok
    end

    render_operation_error(result)
  end

  # DELETE /lessons/:id
  def destroy
    result = run Lesson::Operation::Destroy,
                  with: { params: params } do |_result|
      return head :no_content
    end

    render_operation_error(result, default_status: :not_found)
  end

  private

  def lesson_params
    params.expect(
      lesson: [ :course_id, :title, :content_type, :position ]
    )
  end
end
