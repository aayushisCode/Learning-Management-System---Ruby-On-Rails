
module UserQuiz::Operation
  class Submit < Trailblazer::Operation
    step :find_attempt
    step :calculate_result
    step :submit_attempt

    fail :handle_failure

    def find_attempt(ctx, params:, current_user:, **)
      ctx[:model] = UserQuiz.joins(:user_course)
                            .find_by(
                              id: params[:id],
                              user_courses: { user_id: current_user.id }
                            )

      unless ctx[:model]
        ctx[:error] = {
          msg: "Quiz attempt not found",
          status: :not_found
        }
        return false
      end

      unless ctx[:model].status == "in_progress"
        ctx[:error] = {
          msg: "This quiz attempt has already been submitted",
          status: :conflict
        }
        return false
      end

      true
    end

    def calculate_result(ctx, **)
      user_quiz = ctx[:model]
      quiz = user_quiz.quiz

      questions = quiz.questions
      total_marks = questions.sum(:marks).to_d

      correct_question_ids = UserOption
        .where(user_quiz_id: user_quiz.id)
        .joins(:question)
        .where("questions.correct_option_id = user_options.option_id")
        .pluck(:question_id)

      score = questions.where(id: correct_question_ids).sum(:marks).to_d

      percentage = if total_marks.zero?
                     0
      else
                     (score / total_marks * 100).round(2)
      end

      result = if percentage >= quiz.pass_marks
                 "pass"
      else
                 "fail"
      end

      ctx[:score] = score
      ctx[:total_marks] = total_marks
      ctx[:percentage] = percentage
      ctx[:result] = result

      true
    end

    def submit_attempt(ctx, **)
      user_quiz = ctx[:model]

      user_quiz.with_lock do
        unless user_quiz.status == "in_progress"
          ctx[:error] = {
            msg: "This quiz attempt has already been submitted",
            status: :conflict
          }
          return false
        end

        unless user_quiz.update(
          score: ctx[:score],
          total_marks: ctx[:total_marks],
          percentage: ctx[:percentage],
          result: ctx[:result],
          status: "submitted",
          submitted_at: Time.current
        )
          ctx[:errors] = user_quiz.errors.full_messages
          ctx[:error] = {
            msg: "Unable to submit quiz",
            status: :unprocessable_entity
          }
          return false
        end
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Unable to submit quiz",
        status: :unprocessable_entity
      }
    end
  end
end
