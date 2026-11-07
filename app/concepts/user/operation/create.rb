
module User::Operation
  class Create < Trailblazer::Operation
    step Model(User, :new)
    step :create_user
    fail :handle_failure

    def create_user(ctx, user_params:, **)
      ctx[:model].assign_attributes(user_params)

      if ctx[:model].save
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "User creation failed",
        status: :unprocessable_entity
      }
    end
  end
end
