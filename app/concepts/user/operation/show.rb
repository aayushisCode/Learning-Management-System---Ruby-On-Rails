
module User::Operation
  class Show < Trailblazer::Operation
    step Model(User, :find_by)
    fail :handle_failure

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "User not found",
        status: :not_found
      }
    end
  end
end
