module Api
  class LessonsController < ApplicationController
    def index
      result = run Lesson::Operation::Index do |result|
        return render_operation_response(result)
      end

      render_operation_error(result, default_status: :internal_server_error)
    end

    def create
      result = run Lesson::Operation::Create do |result|
        return render_operation_response(result)
      end

      render_operation_error(result)
    end

    # GET /lessons/:id
    def show
      result = run Lesson::Operation::Show do |result|
        return render_operation_response(result)
      end

      render_operation_error(result, default_status: :not_found)
    end

    # PATCH /lessons/:id
    def update
      result = run Lesson::Operation::Update do |result|
        return render_operation_response(result)
      end

      render_operation_error(result)
    end

    # DELETE /lessons/:id
    def destroy
      result = run Lesson::Operation::Destroy do |_result|
        return render_operation_response(_result)
      end

      render_operation_error(result, default_status: :not_found)
    end

  end
end
