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
        ctx[:error] = "Course assignment not found"
        return false
      end

      true
    end

    def find_quiz(ctx, params:, **)
      ctx[:quiz] = Quiz.find_by(id: params[:quiz_id])

      unless ctx[:quiz]
        ctx[:error] = "Quiz not found"
        return false
      end

      true
    end

    def validate_quiz_access(ctx, **)
      user_course = ctx[:user_course]
      quiz = ctx[:quiz]

      unless user_course.course_id == quiz.course_id
        ctx[:error] = "This quiz does not belong to the assigned course"
        return false
      end

      # Do not allow a second active attempt.
      active_attempt = user_course.user_quizzes.find_by(
        quiz_id: quiz.id,
        status: "in_progress"
      )

      if active_attempt
        ctx[:error] = "You already have an active attempt for this quiz"
        return false
      end

      if quiz.quiz_type == "lesson"
        lesson_progress = user_course.lesson_progresses.find_by(
          lesson_id: quiz.lesson_id,
          status: "completed"
        )

        unless lesson_progress
          ctx[:error] = "Complete the lesson before starting its quiz"
          false
        end
      elsif quiz.quiz_type == "final"
        unless all_lessons_completed?(user_course)
          ctx[:error] = "Complete all lessons before starting the final quiz"
          return false
        end

        unless all_lesson_quizzes_passed?(user_course)
          ctx[:error] = "Pass all lesson quizzes before starting the final quiz"
          false
        end
      end
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
        ctx[:error] = ctx[:model].errors.full_messages
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "Unable to start quiz"
    end

    private

    def all_lessons_completed?(user_course)
      total_lessons = user_course.course.lessons.count

      completed_lessons = user_course.lesson_progresses.where(status: "completed").distinct.count(:lesson_id)

      completed_lessons == total_lessons
    end

    def all_lesson_quizzes_passed?(user_course)
      lesson_quiz_ids = user_course.course.quizzes.where(quiz_type: "lesson").pluck(:id)

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
