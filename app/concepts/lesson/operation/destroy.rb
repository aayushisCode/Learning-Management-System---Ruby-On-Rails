
module Lesson::Operation
  class Destroy < ApplicationOperation
    step :find_lesson
    step :destroy_lesson
    fail :handle_failure
    step :set_response

    def find_lesson(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, Lesson).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :destroy?)
      true
    end

    def destroy_lesson(ctx, **)
      if ctx[:model].destroy
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def set_response(ctx, **)
      ctx[:response_data] = { message: "Lesson deleted successfully" }
      ctx[:status] = :ok
    end

    def handle_failure(ctx, **)
      ctx[:error] = if ctx[:model].nil?
        {
          msg: "Lesson not found",
          status: :not_found
        }
      else
        {
          msg: "Lesson deletion failed",
          status: :unprocessable_entity
        }
      end
    end
  end
end
