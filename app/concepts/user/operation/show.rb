
module User::Operation
  class Show < ApplicationOperation
    step :find_user
    fail :handle_failure

    def find_user(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, User).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :show?)
      ctx[:response_data] = { data: ctx[:model] }
      ctx[:status] = :ok
      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "User not found",
        status: :not_found
      }
    end
  end
end
