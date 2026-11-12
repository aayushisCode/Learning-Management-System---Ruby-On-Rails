
module Course::Operation
  class Create < Trailblazer::Operation
    step :check_admin
    step Model(Course, :new)
    step :build_course
    fail :handle_failure

    def check_admin(ctx, current_user:, **)
      unless current_user&.admin?
        ctx[:error] = {
          msg: "Only admin can create courses",
          status: :forbidden
        }
        return false
      end

      true
    end

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
