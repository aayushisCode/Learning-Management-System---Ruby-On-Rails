
module Quiz::Operation
  class Destroy < Trailblazer::Operation
    step Model(Quiz, :find_by)
    step :destroy_quiz
    fail :handle_failure

    def destroy_quiz(ctx, **)
      unless ctx[:model].destroy
        ctx[:errors] = ctx[:model].errors.full_messages
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= if ctx[:model].nil?
        {
          msg: "Quiz not found",
          status: :not_found
        }
      else
        {
          msg: "Unable to delete quiz",
          status: :unprocessable_entity
        }
      end
    end
  end
end
