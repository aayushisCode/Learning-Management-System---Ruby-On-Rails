module Category::Operation
  class Update < ApplicationOperation
    step :find_category
    step :update_category
    fail :handle_failure
    step :success_response

    def find_category(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, Category).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :update?)
      true
    end

    def update_category(ctx, params:, **)
      attributes = params.require(:category).permit(:category_name, :description)
      ctx[:model].update(attributes)
    end

    def success_response(ctx, **)
      ctx[:response_data] = {
        msg: "Category updated successfully",
        data: ctx[:model].as_json(
          only: %i[id category_name description created_at updated_at]
        )
      }
      ctx[:status] = :ok
    end

    def handle_failure(ctx, **)
      if ctx[:model].nil?
        ctx[:response_data] = { msg: "Category not found" }
        ctx[:status] = :not_found
      else
        ctx[:response_data] = {
          msg: "Category update failed",
          errors: ctx[:model].errors.full_messages
        }
        ctx[:status] = :unprocessable_entity
      end
    end
  end
end
