module User::Operation
  class Index < Trailblazer::Operation
    step :fetch_users
    fail :handle_failure

    def fetch_users(ctx, **)
      ctx[:models] = User.all
      true
    rescue StandardError => e
      ctx[:error] = e.message
      false
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "Unable to fetch users"
    end
  end
end
