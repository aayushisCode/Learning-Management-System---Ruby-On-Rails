
module Quiz::Operation
  class Show < Trailblazer::Operation
    step Model(Quiz, :find_by)
    fail :handle_failure

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Quiz not found",
        status: :not_found
      }
    end
  end
end
