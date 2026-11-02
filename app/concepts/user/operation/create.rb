module User::Operation
  class Create < Trailblazer::Operation
    step :create_user
    fail :handle_failure

    def create_user(ctx, user_params:, **)
      ctx[:model] = User.new(user_params)

      if ctx[:model].save
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "User creation failed"
    end
  end
end
