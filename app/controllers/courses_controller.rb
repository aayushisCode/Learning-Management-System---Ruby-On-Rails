
class CoursesController < ApplicationController
  # GET /courses
  def index
    result = Course::Operation::Index.call

    if result.success?
      render json: result[:models].as_json(
        only: [ :id, :category_id, :title, :description, :status, :created_at, :updated_at ]
      ), status: :ok
    else
      render json: { error: result[:error] },
             status: :internal_server_error
    end
  end

  # GET /courses/:id
  def show
    result = Course::Operation::Show.call(params: params)

    if result.success?
      render json: result[:model].as_json(
        only: [ :id, :category_id, :title, :description, :status, :created_at, :updated_at ]
      ), status: :ok
    else
      render json: { error: result[:error] },
             status: :not_found
    end
  end

  # POST /courses
  def create
    result = Course::Operation::Create.call(course_params: course_params)

    if result.success?
      render json: result[:model].as_json(
        only: [ :id, :category_id, :title, :description, :status, :created_at, :updated_at ]
      ), status: :created
    else
      render json: { errors: result[:errors] || result[:error] },
             status: :unprocessable_entity
    end
  end

  # PATCH /courses/:id
  def update
    result = Course::Operation::Update.call(
      params: params,
      course_params: course_params
    )

    if result.success?
      render json: result[:model].as_json(
        only: [ :id, :category_id, :title, :description, :status, :created_at, :updated_at ]
      ), status: :ok
    else
      render json: { errors: result[:errors] || result[:error] },
             status: :unprocessable_entity
    end
  end

  # DELETE /courses/:id
  def destroy
    result = Course::Operation::Destroy.call(params: params)

    if result.success?
      render json: { message: "Course deleted successfully" },
             status: :ok
    else
      render json: { error: result[:error] },
             status: :not_found
    end
  end

  private

  def course_params
    params.expect(course: [ :category_id, :title, :description, :status ])
  end
end
