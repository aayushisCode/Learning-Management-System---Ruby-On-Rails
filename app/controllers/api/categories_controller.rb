
module Api
  class CategoriesController < ApplicationController

    def index
      result = run Category::Operation::Index do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    def show
      result = run Category::Operation::Show do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :not_found)
    end

    def create
      result = run Category::Operation::Create do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    def update
      result = run Category::Operation::Update do |result|
        return render_operation_response(result)
      end
      render_operation_error(result)
    end

    def destroy
      result = run Category::Operation::Destroy do |result|
        return render_operation_response(result)
      end
      render_operation_error(result, default_status: :not_found)
    end

    private

  end
end
