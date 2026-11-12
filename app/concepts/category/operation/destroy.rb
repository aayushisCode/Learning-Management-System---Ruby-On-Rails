module Category::Operation
  class Destroy < Trailblazer::Operation
    step :check_admin
    step Model(Category, :find_by)
    step :delete_category

    fail :handle_failure

    def check_admin(ctx, current_user:, **)
      unless current_user&.admin?
        ctx[:error] = {
          msg: "Only admin can delete categories",
          status: :forbidden
        }
        return false
      end

      true
    end

    def delete_category(ctx, **)
      if ctx[:model].destroy
        ctx[:response_data] = {
          msg: "Category deleted successfully"
        }
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= if ctx[:model].nil?
        {
          msg: "Category not found",
          status: :not_found
        }
      else
        {
          msg: "Category deletion failed",
          status: :unprocessable_entity
        }
      end
    end
  end
end
