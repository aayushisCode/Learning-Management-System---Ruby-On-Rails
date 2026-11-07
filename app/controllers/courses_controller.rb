# Course Controller
class CoursesController < ApplicationController
  # GET /courses
  def index
    result = run Course::Operation::Index do |result|
      return render json: {
        data: result[:models].as_json(
          only: [
            :id, :category_id, :title, :description,
            :status, :created_at, :updated_at
          ]
        )
      }, status: :ok
    end

    render json: {
      error: result[:error][:msg]
    }, status: result[:error][:code]
  end

  # GET /courses/:id
  def show
    result = run Course::Operation::Show,
                  with: { params: params } do |result|
      return render json: {
        data: result[:model].as_json(
          only: [
            :id, :category_id, :title, :description,
            :status, :created_at, :updated_at
          ]
        )
      }, status: :ok
    end

    render json: {
      error: result[:error][:msg]
    }, status: result[:error][:code]
  end

  # POST /courses
  def create
    result = run Course::Operation::Create,
                  with: { course_params: course_params } do |result|
      return render json: {
        data: result[:model].as_json(
          only: [
            :id, :category_id, :title, :description,
            :status, :created_at, :updated_at
          ]
        )
      }, status: :created
    end

    render json: {
      error: result[:error][:msg],
      errors: result[:errors]
    }, status: result[:error][:code]
  end

  # PATCH /courses/:id
  def update
    result = run Course::Operation::Update,
                  with: {
                    params: params,
                    course_params: course_params
                  } do |result|
      return render json: {
        data: result[:model].as_json(
          only: [
            :id, :category_id, :title, :description,
            :status, :created_at, :updated_at
          ]
        )
      }, status: :ok
    end

    render json: {
      error: result[:error][:msg],
      errors: result[:errors]
    }, status: result[:error][:code]
  end

  # DELETE /courses/:id
  def destroy
    result = run Course::Operation::Destroy,
                  with: { params: params } do |_result|
      return render json: {
        message: "Course deleted successfully"
      }, status: :ok
    end

    render json: {
      error: result[:error][:msg]
    }, status: result[:error][:code]
  end

  private

  def course_params
    params.expect(course: [ :category_id, :title, :description, :status ])
  end
end
