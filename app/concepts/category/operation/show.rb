module Category::Operation
  class Show < Trailblazer::Operation
    step :find_category
    fail :category_not_found

    def find_category(ctx, params:, **)
      ctx[:model] = Category.find_by(id: params[:id])
      return false unless ctx[:model]

      true
    end

    def category_not_found(ctx, **)
      ctx[:error] = "Category not found"
    end
  end
end
