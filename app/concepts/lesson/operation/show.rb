
module Lesson::Operation
  class Show < Trailblazer::Operation
    step Model(Lesson, :find_by, :model)
    fail :handle_failure

    def handle_failure(ctx, **)
      ctx[:error] = {
        msg: "Lesson not found",
        status: :not_found
      }
    end
  end
end
