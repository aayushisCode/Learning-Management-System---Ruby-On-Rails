module Category::Operation
  class Create < Trailblazer::Operation
    step :create_category

    def create_category(ctx, category_params:, **)
      ctx[:model] = Category.new(category_params)

      if ctx[:model].save
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        ctx[:error] = "Unable to create category"
        false
      end
    end
  end
end
