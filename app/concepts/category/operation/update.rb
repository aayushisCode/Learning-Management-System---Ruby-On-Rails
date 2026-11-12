module Category::Operation
  class Update < Trailblazer::Operation
    step Model(Category, :find_by)
    step :update_category
    fail :handle_failure

    def update_category(ctx, category_params:, **)
      if ctx[:model].update(category_params)
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
          msg: "Category update failed",
          status: :unprocessable_entity
        }
      end
    end
  end
end
