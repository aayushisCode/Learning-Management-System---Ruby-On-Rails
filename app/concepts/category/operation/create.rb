module Category::Operation
  class Create < ApplicationOperation
    step :authorize_create
    step Model(Category, :new)
    step :create_category
    fail :handle_failure
    step :success_response

    def authorize_create(ctx, **)
      authorize_record(ctx, Category, :create?)
    end

    def create_category(ctx, params:, **)
      attributes = params.require(:category).permit(:category_name, :description)
      ctx[:model].assign_attributes(attributes)
      ctx[:model].save
    end

    def success_response(ctx, **)
      ctx[:response_data] = {
        msg: "Category created successfully",
        data: ctx[:model].as_json(
          only: %i[id category_name description created_at updated_at]
        )
      }
      ctx[:status] = :created
    end

    def handle_failure(ctx, **)
      ctx[:response_data] = {
        msg: "Unable to create category",
        errors: ctx[:model]&.errors&.full_messages
      }
      ctx[:status] = :unprocessable_entity
    end
  end
end
