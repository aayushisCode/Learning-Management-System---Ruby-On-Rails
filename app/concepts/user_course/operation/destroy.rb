module UserCourse::Operation
  class Destroy < ApplicationOperation
    step :find_user_course
    step :destroy_user_course

    fail :handle_failure

    def find_user_course(ctx, params:, **)
      ctx[:user_course] = policy_scope_for(ctx, UserCourse).find_by(id: params[:id])
      return false unless ctx[:user_course]
      authorize_record(ctx, ctx[:user_course], :destroy?)
    end

    def destroy_user_course(ctx, **)
      user_course = ctx[:user_course]
      # Rails.logger.info "BEFORE DELETE: #{user_course.id}"
      user_course.destroy!

      # Rails.logger.info "AFTER DELETE: #{user_course.id}"
      # Rails.logger.info "DESTROYED?: #{user_course.destroyed?}"
      ctx[:model] = user_course
      ctx[:response_data] = { message: "User_Course deleted successfully" }
      ctx[:status] = :ok
      true

    rescue ActiveRecord::RecordNotDestroyed => e
      Rails.logger.warn(
        "UserCourse deletion blocked: #{user_course.errors.full_messages}"
      )

      ctx[:error] = {
        msg: "Cannot delete this assignment because quiz attempts are associated with it.",
        status: :unprocessable_entity
      }

      false

    rescue StandardError => e
      Rails.logger.error(
        "UserCourse deletion failed: #{e.class} - #{e.message}"
      )

      Rails.logger.error(e.full_message)

      ctx[:error] = {
        msg: "An unexpected error occurred while deleting the course assignment.",
        status: :internal_server_error
      }

      false
    end
    # Failure handling
    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Course assignment deletion failed.",
        status: :unprocessable_entity
      }
    end
  end
end
