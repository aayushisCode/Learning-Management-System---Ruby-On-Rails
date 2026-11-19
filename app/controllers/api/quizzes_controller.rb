module Api
  class QuizzesController < ApplicationController
    def index
      result = run Quiz::Operation::Index do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :internal_server_error)
    end

    def show
      result = run Quiz::Operation::Show do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :not_found)
    end

    def create
      result = run Quiz::Operation::Create do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    def update
      result = run Quiz::Operation::Update do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    def destroy
      result = run Quiz::Operation::Destroy do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :not_found)
    end

    def start
      result = run UserQuiz::Operation::Start do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    def attempt
      result = run UserQuiz::Operation::Show do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :not_found)
    end

    def answer
      result = run UserOption::Operation::Create do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    def submit
      result = run UserQuiz::Operation::Submit do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    def report_card
      result = run UserQuiz::Operation::ReportCard do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :not_found)
    end
  end
end
