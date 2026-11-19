
module User::Operation
  class Index < ApplicationOperation
    step :fetch_users
    fail :handle_failure

    def fetch_users(ctx, **)
      authorize_record(ctx, User, :index?)
      ctx[:models] = policy_scope_for(ctx, User).to_a
      ctx[:response_data] = { data: ctx[:models].as_json(only: [:id, :email, :role_id, :created_at, :updated_at]) }
      ctx[:status] = :ok
      true
    rescue StandardError => e
      Rails.logger.error("User Index Error: #{e.full_message}")
      false
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Unable to fetch users",
        status: :internal_server_error
      }
    end
  end
end
