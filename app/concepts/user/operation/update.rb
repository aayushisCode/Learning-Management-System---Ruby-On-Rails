
module User::Operation
  class Update < Trailblazer::Operation
    step Model(User, :find_by)
    step :update_user
    fail :handle_failure

    def update_user(ctx, user_params:, **)
      unless ctx[:model].update(user_params)
        ctx[:errors] = ctx[:model].errors.full_messages
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= if ctx[:model].nil?
        {
          msg: "User not found",
          status: :not_found
        }
      else
        {
          msg: "User update failed",
          status: :unprocessable_entity
        }
      end
    end
  end
end
