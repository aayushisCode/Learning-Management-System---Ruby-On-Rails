
module Course::Operation
  class Destroy < ApplicationOperation
    step :find_course
    step :delete_course
    fail :handle_failure

    def find_course(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, Course).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :destroy?)
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
