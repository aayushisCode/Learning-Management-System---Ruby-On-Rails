
module Course::Operation
  class Show < ApplicationOperation
    step :find_course
    fail :handle_failure
    step :success_response

    def success_response(ctx, **)
      ctx[:response_data] = {
        data: ctx[:model].as_json(
          only: %i[ id category_id title description status ]
        )
      }
      ctx[:status] = :ok
    end

    def handle_failure(ctx, **)
      ctx[:response_data] = {
        msg: "Course not found"
      }
      ctx[:status] = :not_found
    end
  end
end
    def find_course(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, Course).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :show?)
      true
    end
