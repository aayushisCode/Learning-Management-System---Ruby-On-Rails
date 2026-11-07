
module Question::Operation
  class Show < Trailblazer::Operation
    step Model(Question, :find_by)

    fail :handle_failure

    def handle_failure(ctx, **)
      ctx[:error] = {
        msg: "Question not found",
        status: :not_found
      }
    end
  end
end
