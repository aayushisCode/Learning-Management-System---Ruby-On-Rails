module User::Operation
  class Show < Trailblazer::Operation
    step :find_user
    # ctx: Trailblazer's context, where we store data that later steps or the controller can access.
    def find_user(ctx, params:, **)
      ctx[:model] = User.find(params[:id])
    end
  end
end
