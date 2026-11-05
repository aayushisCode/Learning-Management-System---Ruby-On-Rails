module Question::Operation
  class Show < Trailblazer::Operation
    step :find_question
    fail :handle_failure

    def find_question(ctx, params:, **)
      ctx[:model] = Question.find_by(id: params[:id])

      unless ctx[:model]
        ctx[:error] = "Question not found"
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "Unable to fetch question"
      true
    end
  end
end
