
module Question::Operation
  class Destroy < Trailblazer::Operation
    step Model(Question, :find_by)
    step :destroy_question

    fail :handle_failure

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
