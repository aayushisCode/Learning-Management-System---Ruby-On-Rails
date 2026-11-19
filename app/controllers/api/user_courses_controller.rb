
module Api
  class UserCoursesController < ApplicationController
    # GET /api/user_courses
    def index
      result = run UserCourse::Operation::Index do |result|
        return render_operation_response(result)
      end

      render_operation_error(
        result,
        default_status: :internal_server_error
      )
    end

    # GET /api/user_courses/:id
    def show
      result = run UserCourse::Operation::Show do |result|
        return render_operation_response(result)
      end

      render_operation_error(result, default_status: :not_found)
    end

    # POST /api/user_courses
    def create
      result = run UserCourse::Operation::Create do |result|
        return render_operation_response(result)
      end

      render_operation_error(result)
    end

    # DELETE /api/user_courses/:id
    def destroy
      result = run UserCourse::Operation::Destroy do |_result|
        return render_operation_response(_result)
      end

      render_operation_error(result, default_status: :not_found)
    end

    private

  end
end
