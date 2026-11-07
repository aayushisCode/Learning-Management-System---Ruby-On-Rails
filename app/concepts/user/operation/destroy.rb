
module User::Operation
  class Destroy < Trailblazer::Operation
    step Model(User, :find_by)
    step :destroy_user
    fail :handle_failure

    def destroy_user(ctx, **)
      unless ctx[:model].destroy
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
          msg: "Failed to delete user",
          status: :unprocessable_entity
        }
      end
    end
  end
end
