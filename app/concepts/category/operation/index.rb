module Category::Operation
  class Index < ApplicationOperation
    step :fetch_categories
    fail :handle_failure
    step :success_response

    def fetch_categories(ctx, **)
       # Rails.logger.info("INDEX INPUT: #{ctx.inspect}")

      pundit = Pundit::Context.new(user: ctx[:current_user])
      pundit.authorize(Category, query: :index?, policy_class: nil)
      ctx[:models] = pundit.policy_scope(Category).to_a
      # Rails.logger.info("FETCHED CATEGORIES: #{ctx[:models].count}")

      true
    rescue StandardError => e
      Rails.logger.error("Category Index Error: #{e.full_message}")
      false
    end

    def handle_failure(ctx, **)
      ctx[:response_data] = {
        msg: "Unable to fetch categories"
      }
      ctx[:status] = :internal_server_error
    end

    def success_response(ctx, **)
      ctx[:response_data] = {
        data: ctx[:models].as_json(
          only: %i[id category_name description created_at updated_at]
        )
      }
      ctx[:status] = :ok
    end


  end
end
