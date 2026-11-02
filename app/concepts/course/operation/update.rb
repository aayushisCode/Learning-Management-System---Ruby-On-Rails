module Course::Operation
  class Update < Trailblazer::Operation
    step :find_course
    step :update_course
    fail :handle_failure

    def find_course(ctx, params:, **)
      ctx[:model] = Course.find_by(id: params[:id])

      return false unless ctx[:model]

      true
    end

    def update_course(ctx, course_params:, **)
      if ctx[:model].update(course_params)
        true
      else
        # ctx[:errors] = ctx[:model].errors.full_messages
        # false
        false unless ctx[:model].update(course_params)
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "Course update failed"
    end
  end
end
