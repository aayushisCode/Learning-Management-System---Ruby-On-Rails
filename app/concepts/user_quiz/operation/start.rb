
module UserQuiz::Operation
  class Start < Trailblazer::Operation
    step :find_user_course
    step :find_quiz
    step :validate_quiz_access
    step :create_attempt

    fail :handle_failure

    def find_user_course(ctx, params:, current_user:, **)
      ctx[:user_course] = UserCourse.find_by(
        id: params[:user_course_id],
        user_id: current_user.id
      )

      unless ctx[:user_course]
        ctx[:error] = {
          msg: "Course assignment not found",
          status: :not_found
        }
        return false
      end

      true
    end

    def find_quiz(ctx, params:, **)
      ctx[:quiz] = Quiz.find_by(id: params[:quiz_id])

      unless ctx[:quiz]
        ctx[:error] = {
          msg: "Quiz not found",
          status: :not_found
        }
        return false
      end

      true
    end

    def validate_quiz_access(ctx, **)
      user_course = ctx[:user_course]
      quiz = ctx[:quiz]

      unless user_course.course_id == quiz.course_id
        ctx[:error] = {
          msg: "This quiz does not belong to the assigned course",
          status: :unprocessable_entity
        }
        return false
      end

      active_attempt = user_course.user_quizzes.find_by(
        quiz_id: quiz.id,
        status: "in_progress"
      )

      if active_attempt
        ctx[:error] = {
          msg: "You already have an active attempt for this quiz",
          status: :conflict
        }
        return false
      end

      case quiz.quiz_type
      when "lesson"
        lesson_progress = user_course.lesson_progresses.find_by(
          lesson_id: quiz.lesson_id,
          status: "completed"
        )

        unless lesson_progress
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

    def create_attempt(ctx, **)
      user_course = ctx[:user_course]
      quiz = ctx[:quiz]

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
      total_lessons = user_course.course.lessons.count

      completed_lessons = user_course.lesson_progresses
                                     .where(status: "completed")
                                     .distinct
                                     .count(:lesson_id)

      completed_lessons == total_lessons
    end

    def all_lesson_quizzes_passed?(user_course)
      lesson_quiz_ids = user_course.course.quizzes
                                   .where(quiz_type: "lesson")
                                   .pluck(:id)

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
