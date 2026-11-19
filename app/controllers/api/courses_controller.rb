module Api
  class CoursesController < ApplicationController
    # GET /api/courses
    def index
      result = run Course::Operation::Index do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :internal_server_error)
    end

    # GET /api/courses/id
    def show
      result = run Course::Operation::Show do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :not_found)
    end

    # POST /api/courses
    def create
      result = run Course::Operation::Create do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    # PATCH /api/courses/:id
    def update
      result = run Course::Operation::Update do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    # DELETE /api/courses/:id
    def destroy
      result = run Course::Operation::Destroy do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :not_found)
    end

    private

  end
end
