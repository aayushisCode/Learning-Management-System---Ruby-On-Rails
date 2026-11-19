module Api
  class QuestionsController < ApplicationController
    def index
      result = run Question::Operation::Index do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :internal_server_error)
    end

    def show
      result = run Question::Operation::Show do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :not_found)
    end

    def create
      result = run Question::Operation::Create do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    def update
      result = run Question::Operation::Update do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    def destroy
      result = run Question::Operation::Destroy do |_result|
        return head :no_content
      end
      render_operation_error(result, default_status: :not_found)
    end
  end
end
