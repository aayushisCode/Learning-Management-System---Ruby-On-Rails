
module Lesson::Operation
  class Show < ApplicationOperation
    step :find_user_course
    step :find_lesson
    fail :handle_failure
    step :set_response

    def find_user_course(ctx, params:, **)
      return true if params[:user_course_id].blank?

      user_course = policy_scope_for(ctx, UserCourse)
                    .includes(:user_lesson_progresses, :user_quizzes)
                    .find_by(id: params[:user_course_id])
      unless user_course
        ctx[:error] = { msg: "Course assignment not found", status: :not_found }
        return false
      end

      authorize_record(ctx, user_course, :show?)
      ctx[:user_course] = user_course
    end

    def find_lesson(ctx, params:, user_course: nil, **)
      lesson_scope = if user_course
                       user_course.course.lessons
                     else
                       policy_scope_for(ctx, Lesson)
                     end
      ctx[:model] = lesson_scope.includes(:lesson_pages, :quizzes).find_by(id: params[:id])
      unless ctx[:model]
        ctx[:error] = { msg: "Lesson not found", status: :not_found }
        return false
      end

      authorize_record(ctx, ctx[:model], :show?)
      true
    end

    def set_response(ctx, user_course: nil, **)
      lesson = ctx[:model]
      pages = lesson.lesson_pages.order(:position)
      progress = user_course&.user_lesson_progresses&.find_by(lesson_id: lesson.id)
      quiz = lesson.quizzes.find { |item| item.quiz_type == "lesson" }
      quiz_attempts = if quiz && user_course
                        user_course.user_quizzes.select { |attempt| attempt.quiz_id == quiz.id }
                      else
                        []
                      end
      latest_attempt = quiz_attempts.max_by(&:attempt_number)
      quiz_passed = quiz_attempts.any? { |attempt| attempt.status == "submitted" && attempt.result == "pass" }
      calculation = if user_course
                      Progress::LessonCalculator.call(
                        lesson: lesson,
                        progress: progress,
                        quiz: quiz,
                        quiz_passed: quiz_passed,
                        quiz_attempted: quiz_attempts.any?
                      )
                    end
      page_metadata = progress&.metadata&.fetch("pages", {}) || {}
      current_page_number = current_page_number_for(user_course, lesson)
      current_page = pages.to_a[current_page_number - 1] if current_page_number

      ctx[:response_data] = {
        data: {
          id: lesson.id,
          course_id: lesson.course_id,
          title: lesson.title,
          content_type: lesson.content_type,
          position: lesson.position,
          lesson_pages_count: pages.size,
          lesson_pages: pages.map do |page|
            {
              id: page.id,
              title: page.title,
              topic: page.topic,
              content: page.content,
              metadata: page.metadata,
              position: page.position,
              user_lesson_progress: {
                completed: page_metadata.dig(page.id.to_s, "completed") == true
              }
            }
          end,
          current_page: current_page && {
            id: current_page.id,
            page_number: current_page_number,
            position: current_page.position
          },
          lesson_progress: calculation && {
            id: progress&.id,
            status: calculation[:status],
            completed_pages: calculation[:completed_pages],
            total_pages: calculation[:total_pages],
            progress_percentage: calculation[:progress_percentage],
            started_at: progress&.started_at,
            completed_at: progress&.completed_at
          },
          lesson_quiz: quiz && quiz_payload(quiz, latest_attempt),
          created_at: lesson.created_at,
          updated_at: lesson.updated_at
        }
      }
      ctx[:status] = :ok
    end

    def current_page_number_for(user_course, lesson)
      return unless user_course
      return user_course.current_page_number if user_course.current_lesson_id == lesson.id
      return unless user_course.current_lesson_id.nil?

      first_lesson = user_course.course.lessons.order(:position).first
      1 if first_lesson&.id == lesson.id
    end

    def quiz_payload(quiz, attempt)
      submitted = attempt&.status == "submitted"
      {
        id: quiz.id,
        title: quiz.title,
        quiz_type: quiz.quiz_type,
        pass_marks: quiz.pass_marks,
        status: attempt&.status || "pending",
        attempt_number: attempt&.attempt_number,
        result: submitted ? attempt.result : nil,
        score: submitted ? attempt.score : nil,
        total_marks: submitted ? attempt.total_marks : nil,
        percentage: submitted ? attempt.percentage : nil,
        submitted_at: submitted ? attempt.submitted_at : nil
      }
    end

    def handle_failure(ctx, **)
      ctx[:error] = {
        msg: "Lesson not found",
        status: :not_found
      }
    end
  end
end
