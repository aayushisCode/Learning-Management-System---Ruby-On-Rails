
module Category::Operation
  class Destroy < ApplicationOperation
    step :find_category
    step :delete_category
    fail :handle_failure
    step :success_response

    def find_category(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, Category).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :destroy?)
      true
    end

    def delete_category(ctx, **)
      ctx[:model].destroy
    end

    def success_response(ctx, **)
      ctx[:response_data] = {
        msg: "Category deleted successfully"
      }
      ctx[:status] = :ok
    end

    def handle_failure(ctx, **)
      if ctx[:model].nil?
        ctx[:response_data] = {
          msg: "Category not found"
        }
        ctx[:status] = :not_found
      else
        ctx[:response_data] = {
          msg: "Category deletion failed",
          errors: ctx[:model].errors.full_messages
        }
        ctx[:status] = :unprocessable_entity
      end
    end
  end
end
