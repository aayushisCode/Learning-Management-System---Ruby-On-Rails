
module Course::Operation
  class Update < Trailblazer::Operation
    step Model(Course, :find_by)
    step :update_course
    fail :handle_failure

    def update_course(ctx, course_params:, **)
      if ctx[:model].update(course_params)
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] = if ctx[:model].nil?
        {
          msg: "Course not found",
          status: :not_found
        }
      else
        {
          msg: "Course update failed",
          status: :unprocessable_entity
        }
      end
    end
  end
end
