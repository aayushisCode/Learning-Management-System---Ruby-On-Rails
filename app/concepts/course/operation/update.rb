
module Course::Operation
  class Update < Trailblazer::Operation
    step :check_admin
    step Model(Course, :find_by)
    step :update_course
    fail :handle_failure

    def check_admin(ctx, current_user:, **)
      unless current_user&.admin?
        ctx[:error] = {
          msg: "Only admin can update courses",
          status: :forbidden
        }
        return false
      end

      true
    end

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
