module Category::Operation
  class Show < Trailblazer::Operation
    step Model(Category, :find_by)
    fail :handle_failure

    def handle_failure(ctx, **)
      ctx[:error] = {
        msg: "Category not found",
        status: :not_found
      }
    end
  end
end
