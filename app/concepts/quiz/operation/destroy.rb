
module Quiz::Operation
  class Destroy < ApplicationOperation
    step :destroy_quiz

    fail :handle_failure
    step :set_response

    def destroy_quiz(ctx, params:, **)
      model = policy_scope_for(ctx, Quiz).find_by(id: params[:id])
      return false unless model
      authorize_record(ctx, model, :destroy?)
      unless model.destroy
        ctx[:errors] = model.errors.full_messages
        return false
      end

      true
    end

    def set_response(ctx, **)
      ctx[:response_data] = { message: "Quiz deleted successfully" }
      ctx[:status] = :ok
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: ctx[:errors]&.join(", ") || "Unable to delete quiz",
        status: :unprocessable_entity
      }
    end
  end
end
