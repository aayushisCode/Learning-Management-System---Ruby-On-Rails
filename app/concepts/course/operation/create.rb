
module Course::Operation
  class Create < Trailblazer::Operation
    step :build_course
    fail :handle_validation_failure

    def build_course(ctx, course_params:, **)
      ctx[:model] = Course.new(course_params)

      if ctx[:model].save
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_validation_failure(ctx, **)
      ctx[:error] = "Course creation failed"
    end
  end
end
