module Category::Operation
  class Show < ApplicationOperation
    step :find_category
    fail :handle_failure

    step :success_response

    def find_category(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, Category).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :show?)
      true
    end

    def success_response(ctx, **)
      ctx[:response_data] = {
        data: ctx[:model].as_json(
          only: %i[id category_name description created_at updated_at]
        )
      }

      ctx[:status] = :ok
    end

    def handle_failure(ctx, **)
      ctx[:response_data] = {
        msg: "Category not found"
      }

      ctx[:status] = :not_found
    end
  end
end
