module Question::Operation
  class Destroy < Trailblazer::Operation
    step :find_question
    step :destroy_question
    fail :handle_failure

    def find_question(ctx, params:, **)
      ctx[:model] = Question.find_by(id: params[:id])

      unless ctx[:model]
        ctx[:error] = "Question not found"
        return false
      end

      true
    end

    def destroy_question(ctx, **)
      unless ctx[:model].destroy
        ctx[:error] = ctx[:model].errors.full_messages
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "Unable to delete question"
      true
    end
  end
end
