module User::Operation
  class Update < Trailblazer::Operation
    step :find_user
    fail :user_not_found, fail_fast: true

    step :update_user
    fail :update_failed, fail_fast: true

    def find_user(ctx, params:, **)  # params: Complete request parameters
      ctx[:model] = User.find_by(id: params[:id])

      # if ctx[:model].nil?
      #   ctx[:error] = "User not found"
      #   return false
      # end
      !ctx[:model].nil?
    end

    def user_not_found(ctx, **)
      ctx[:error] = "User not found"
    end

    def update_user(ctx, user_params:, **) # user_params:Permitted user attributes
      ctx[:model].update(user_params)
    end

    def update_failed(ctx, **)
      ctx[:errors] = ctx[:model].errors.full_messages
    end
  end
end
