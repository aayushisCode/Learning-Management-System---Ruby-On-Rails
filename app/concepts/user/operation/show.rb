module User::Operation
  class Show < Trailblazer::Operation
    step :find_user
    fail :handle_failure

    # ctx: Trailblazer's context, where we store data that later steps or the controller can access.
    def find_user(ctx, params:, **)
      ctx[:model] = User.find_by(id: params[:id]) # find : a database record by its primary key.
      # ctx[:model] → Stores the retrieved user in the operation's context under the key :model.
      if ctx[:model].nil?
        ctx[:error] = "User not found"
        return false
      end
      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "User not found"
    end
  end
end
