
module User::Operation
  class Index < Trailblazer::Operation
    step :fetch_users
    fail :handle_failure

    def fetch_users(ctx, **)
      ctx[:models] = User.all.to_a
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
