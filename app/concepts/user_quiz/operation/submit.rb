
module UserQuiz::Operation
  class Submit < ApplicationOperation
    step :find_attempt
    step :validate_attempt
    step :calculate_result
    step :submit_attempt
    step :update_course_progress

    fail :handle_failure
    step :set_response

    def find_attempt(ctx, params:, **)
      model = policy_scope_for(ctx, UserQuiz).find_by(id: params[:id])

      unless model
        ctx[:error] = {
          msg: "Quiz attempt not found",
          status: :not_found
        }
        return false
      end

      unless model.status == "in_progress"
        ctx[:error] = {
          msg: "This quiz attempt has already been submitted",
          status: :conflict
        }
        return false
      end

      authorize_record(ctx, model, :submit?)
      ctx[:model] = model
    end

    def validate_attempt(ctx, model:, **)
      unless model.status == "in_progress"
        ctx[:error] = {
          msg: "This quiz attempt has already been submitted",
          status: :conflict
        }
        return false
      end

      true
    end

    def calculate_result(ctx, model:, **)
      questions = model.quiz.questions
      total_marks = questions.sum(:marks).to_d

      correct_question_ids = UserOption
        .where(user_quiz_id: model.id)
        .joins(:question)
        .where("questions.correct_option_id = user_options.option_id")
        .pluck(:question_id)

      score = questions.where(id: correct_question_ids).sum(:marks).to_d

      percentage = if total_marks.zero?
                     0
      else
                     (score / total_marks * 100).round(2)
      end

      result = if score >= model.quiz.pass_marks
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

    def submit_attempt(ctx, model:, **)
      model.with_lock do
        unless model.status == "in_progress"
          ctx[:error] = {
            msg: "This quiz attempt has already been submitted",
            status: :conflict
          }
          return false
        end

        unless model.update(
          score: ctx[:score],
          total_marks: ctx[:total_marks],
          percentage: ctx[:percentage],
          result: ctx[:result],
          status: "submitted",
          submitted_at: Time.current
        )
          ctx[:errors] = model.errors.full_messages
          ctx[:error] = {
            msg: "Unable to submit quiz",
            status: :unprocessable_entity
          }
          return false
        end
      end

      true
    end

    def update_course_progress(ctx, model:, **)
      Progress::Updater.call(
        user_course: model.user_course
      )

      true
    rescue ActiveRecord::RecordInvalid => e
      ctx[:errors] = e.record.errors.full_messages
      ctx[:error] = {
        msg: "Unable to update course progress",
        status: :internal_server_error
      }

      false
    end

    def set_response(ctx, model:, **)
      ctx[:response_data] = {
        message: "Quiz submitted",
        status: model.status
        # score: ctx[:score],
        # total_marks: ctx[:total_marks],
        # percentage: ctx[:percentage],
        # result: ctx[:result]
      }

      ctx[:status] = :ok
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Unable to submit quiz",
        status: :unprocessable_entity
      }
    end
  end
end
