module Category::Operation
  class Update < Trailblazer::Operation
    step :find_category
    step :update_category
    fail :handle_failure

    def find_category(ctx, params:, **)
      ctx[:model] = Category.find_by(id: params[:id])
      return false unless ctx[:model]

      true
    end
    # update category with the provided parameters
    def update_category(ctx, category_params:, **)
      if ctx[:model].update(category_params)
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "Category update failed"
    end
  end
end
