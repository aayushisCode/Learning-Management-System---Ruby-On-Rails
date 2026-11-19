
module User::Operation
  class Destroy < ApplicationOperation
    step :find_user
    step :destroy_user
    fail :handle_failure

    def find_user(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, User).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :destroy?)
      true
    end

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
