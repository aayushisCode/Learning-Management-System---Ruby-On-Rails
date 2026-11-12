
module Category::Operation
  class Create < Trailblazer::Operation
    step :check_admin
    step Model(Category, :new)
    step :create_category
    fail :handle_failure

    def check_admin(ctx, current_user:, **)
      unless current_user&.admin?
        ctx[:error] = {
          msg: "Only admin can create categories",
          status: :forbidden
        }
        return false
      end

      true
    end

    def create_category(ctx, category_params:, **)
      ctx[:model].assign_attributes(category_params)

      if ctx[:model].save
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Unable to create category",
        status: :unprocessable_entity
      }
    end
  end
end
