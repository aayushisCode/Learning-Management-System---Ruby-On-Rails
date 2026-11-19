module UserCourse::Operation
  class Show < ApplicationOperation
    step :find_user_course
    step :authorize_user_course
    step :build_response

    def find_user_course(ctx, params:, **)
       Rails.logger.info "========== USER COURSE SHOW =========="
       Rails.logger.info "REQUESTED ID: #{params[:id]}"
       Rails.logger.info "CURRENT USER: #{ctx[:current_user]&.id}"

       scope = policy_scope_for(ctx, UserCourse)

       Rails.logger.info "SCOPE COUNT: #{scope.count}"

       ctx[:model] = scope.find_by(id: params[:id])

       Rails.logger.info "FOUND RECORD: #{ctx[:model].inspect}"

      return true if ctx[:model]

      ctx[:error] = {
        msg: "User course not found",
        status: :not_found
      }

      false
    end
    def final_quiz_data(assignment)
      quiz = assignment.course.quizzes.find_by(quiz_type: "final")

      # No final quiz configured for this course
      return nil unless quiz

      attempts = assignment.user_quizzes
                          .where(quiz_id: quiz.id)
                          .order(attempt_number: :desc)
                          .to_a

      passed_attempt = attempts
        .select { |attempt| attempt.status == "submitted" && attempt.result == "pass" }
        .max_by { |attempt| attempt.percentage.to_f }

      active_attempt = attempts.find { |attempt| attempt.status == "in_progress" }

      latest_attempt = attempts.first

      quiz_status =
        if passed_attempt
          "passed"
        elsif active_attempt
          "in_progress"
        elsif latest_attempt&.result == "fail"
          "failed"
        else
          "not_attempted"
        end

      display_attempt = passed_attempt || latest_attempt

      {
        quiz_id: quiz.id,
        quiz_title: quiz.title,
        status: quiz_status,
        score: display_attempt&.score,
        total_marks: display_attempt&.total_marks,
        percentage: display_attempt&.percentage,
        attempts: attempts.size
      }
    end

    def authorize_user_course(ctx, **)
      authorize_record(ctx, ctx[:model], :show?)
    end

    def build_response(ctx, **)
      assignment = ctx[:model]

      ctx[:response_data] = {
        id: assignment.id,
        user_id: assignment.user_id,
        course_id: assignment.course_id,
        assigned_by_id: assignment.assigned_by_id,
        status: assignment.status,
        progress_percentage: assignment.progress_percentage,
        completed_lessons: assignment.completed_lessons,
        total_lessons: assignment.total_lessons,
        assigned_at: assignment.assigned_at,
        due_date: assignment.due_date,
        completed_at: assignment.completed_at,
        resume_position: assignment.resume_position,
        final_quiz: final_quiz_data(assignment)
      }

      true
    end
  end
end
