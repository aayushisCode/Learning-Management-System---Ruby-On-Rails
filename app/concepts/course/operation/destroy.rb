
module Course::Operation
  class Destroy < Trailblazer::Operation
    step :check_admin
    step Model(Course, :find_by)
    step :delete_course
    fail :handle_failure

    def check_admin(ctx, current_user:, **)
      unless current_user&.admin?
        ctx[:error] = {
          msg: "Only admin can delete courses",
          status: :forbidden
        }
        return false
      end

      true
    end

    def delete_course(ctx, **)
      if ctx[:model].destroy
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
          msg: "Course deletion failed",
          status: :unprocessable_entity
        }
      end
    end
  end
end
