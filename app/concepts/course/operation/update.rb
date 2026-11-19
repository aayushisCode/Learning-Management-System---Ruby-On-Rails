
module Course::Operation
  class Update < ApplicationOperation
    step :find_course
    step :update_course
    fail :handle_failure

    def find_course(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, Course).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :update?)
      true
    end

    def update_course(ctx, params:, **)
      attributes = params.require(:course).permit(:category_id, :title, :description, :status)
      if ctx[:model].update(attributes)
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
