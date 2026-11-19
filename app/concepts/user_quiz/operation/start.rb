
module UserQuiz::Operation
  class Start < ApplicationOperation
    step :fetch_records
    step :validate_quiz_course
    step :validate_quiz_access
    step :create_attempt

    fail :handle_failure
    step :set_response

    def validate_quiz_course(ctx, user_course:, quiz:, **)
      unless user_course.course_id == quiz.course_id
        ctx[:error] = {
          msg: "This quiz does not belong to the assigned course",
          status: :unprocessable_entity
        }
        return false
      end

      true
    end

    def validate_quiz_access(ctx, user_course:, quiz:, **)
      active_attempt = user_course.user_quizzes.exists?(
        quiz_id: quiz.id,
        status: "in_progress"
      )
      passed_attempt = user_course.user_quizzes.exists?(
        quiz_id: quiz.id,
        status: "submitted",
        result: "pass"
      )

      if passed_attempt
        ctx[:error] = {
          msg: "You have already passed this quiz",
          status: :conflict
        }
        return false
      end

      if active_attempt
        ctx[:error] = {
          msg: "You already have an active attempt for this quiz",
          status: :conflict
        }
        return false
      end

      case quiz.quiz_type
      when "lesson"
        lesson = user_course.course.lessons.find_by(id: quiz.lesson_id)

        unless lesson && lesson_content_completed?(user_course, lesson)
          ctx[:error] = {
            msg: "Complete the lesson before starting its quiz",
            status: :unprocessable_entity
          }
          return false
        end

      when "final"
        unless all_lessons_completed?(user_course)
          ctx[:error] = {
            msg: "Complete all lessons before starting the final quiz",
            status: :unprocessable_entity
          }
          return false
        end

        unless all_lesson_quizzes_passed?(user_course)
          ctx[:error] = {
            msg: "Pass all lesson quizzes before starting the final quiz",
            status: :unprocessable_entity
          }
          return false
        end

      else
        ctx[:error] = {
          msg: "Invalid quiz type",
          status: :unprocessable_entity
        }
        return false
      end

      true
    end

    def create_attempt(ctx, user_course:, quiz:, **)
      attempt_number = user_course.user_quizzes
                                 .where(quiz_id: quiz.id)
                                 .maximum(:attempt_number).to_i + 1

      ctx[:model] = user_course.user_quizzes.new(
        quiz: quiz,
        attempt_number: attempt_number,
        status: "in_progress",
        started_at: Time.current
      )

      unless ctx[:model].save
        ctx[:errors] = ctx[:model].errors.full_messages
        ctx[:error] = {
          msg: "Unable to start quiz",
          status: :unprocessable_entity
        }
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Unable to start quiz",
        status: :unprocessable_entity
      }
    end

    private

    def all_lessons_completed?(user_course)
      lessons = user_course.course.lessons.to_a

      lessons.any? do |lesson|
        lesson_content_completed?(user_course, lesson)
      end && lessons.all? do |lesson|
        lesson_content_completed?(user_course, lesson)
      end
    end

    def lesson_content_completed?(user_course, lesson)
      progress = user_course.user_lesson_progresses.find_by(
        lesson_id: lesson.id
      )

      return false unless progress

      pages = lesson.lesson_pages.to_a
      return false if pages.empty?

      completed_pages = progress.metadata&.dig("pages") || {}

      pages.all? do |page|
        completed_pages.dig(page.id.to_s, "completed") == true
      end
    end

    def all_lesson_quizzes_passed?(user_course)
      lesson_quiz_ids = user_course.course.quizzes
                                   .where(quiz_type: "lesson")
                                   .pluck(:id)

      lesson_quiz_ids.any? &&
        lesson_quiz_ids.all? do |quiz_id|
          user_course.user_quizzes.exists?(
            quiz_id: quiz_id,
            status: "submitted",
            result: "pass"
          )
        end
    end
  end
end
    def fetch_records(ctx, params:, **)
      user_course = policy_scope_for(ctx, UserCourse).find_by(id: params[:user_course_id])
      return missing_record(ctx, "Course assignment not found") unless user_course
      authorize_record(ctx, user_course, :start_quiz?)

      quiz = policy_scope_for(ctx, Quiz).find_by(id: params[:quiz_id])
      return missing_record(ctx, "Quiz not found") unless quiz
      authorize_record(ctx, quiz, :show?)

      ctx[:user_course] = user_course
      ctx[:quiz] = quiz
    end

    def missing_record(ctx, message)
      ctx[:error] = { msg: message, status: :not_found }
      false
    end

    def set_response(ctx, **)
      attempt = ctx[:model]
      ctx[:response_data] = { message: "Quiz started", user_quiz_id: attempt.id, attempt_number: attempt.attempt_number, started_at: attempt.started_at }
      ctx[:status] = :created
    end
