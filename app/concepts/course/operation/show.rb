
module Course::Operation
  class Show < Trailblazer::Operation
    step Model(Course, :find_by)
    fail :handle_failure

    def handle_failure(ctx, **)
      ctx[:error] = {
        msg: "Course not found",
        status: :not_found
      }
    end
  end
end
