module Api
  class UsersController < ApplicationController
    def index
      result = run User::Operation::Index do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :internal_server_error)
    end

    def show
      result = run User::Operation::Show do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :not_found)
    end

    def create
      result = run User::Operation::Create do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    def update
      result = run User::Operation::Update do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    def destroy
      result = run User::Operation::Destroy do |_result|
        return head :no_content
      end
      render_operation_error(result, default_status: :not_found)
    end
  end
end
