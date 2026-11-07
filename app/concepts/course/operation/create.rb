
module Course::Operation
  class Create < Trailblazer::Operation
    step Model(Course, :new)
    step :build_course
    fail :handle_failure

    def build_course(ctx, course_params:, **)
      ctx[:model].assign_attributes(course_params)

      if ctx[:model].save
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] = {
        msg: "Course creation failed",
        status: :unprocessable_entity
      }
    end
  end
end
