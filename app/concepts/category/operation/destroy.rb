
module Category::Operation
  class Destroy < Trailblazer::Operation
    step Model(Category, :find_by)
    step :delete_category
    fail :handle_failure

    def delete_category(ctx, **)
      if ctx[:model].destroy
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] = if ctx[:model].nil?
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
