module Quiz::Operation
  class Destroy < Trailblazer::Operation
    step :find_quiz
    step :destroy_quiz
    fail :handle_failure

    def find_quiz(ctx, params:, **)
      ctx[:model] = Quiz.find_by(id: params[:id])

      unless ctx[:model]
        ctx[:error] = "Quiz not found"
        return false
      end

      true
    end

    def destroy_quiz(ctx, **)
      unless ctx[:model].destroy
        ctx[:error] = ctx[:model].errors.full_messages
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "Unable to delete quiz"
      true
    end
  end
end
