
module Category::Operation
  class Index < Trailblazer::Operation
    step :fetch_categories
    fail :handle_failure

    def fetch_categories(ctx, **)
      ctx[:models] = Category.all.to_a
    rescue StandardError => e
      Rails.logger.error("Category Index Error: #{e.full_message}")
      false
    end

    def handle_failure(ctx, **)
      ctx[:error] = {
        msg: "Unable to fetch categories",
        status: :internal_server_error
      }
    end
  end
end
