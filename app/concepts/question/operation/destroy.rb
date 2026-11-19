
module Question::Operation
  class Destroy < ApplicationOperation
    step :find_question
    step :destroy_question

    fail :handle_failure

    def find_question(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, Question).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :destroy?)
      true
    end

    def destroy_question(ctx, **)
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
          msg: "Question not found",
          status: :not_found
        }
      else
        {
          msg: "Unable to delete question",
          status: :unprocessable_entity
        }
      end
    end
  end
end
