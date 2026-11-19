
module UserCourse::Operation
  class Index < ApplicationOperation
    step :fetch_user_courses

    def fetch_user_courses(ctx, params:, **)
      authorize_record(ctx, UserCourse, :index?)
      user_courses = policy_scope_for(ctx, UserCourse)
      user_courses = user_courses.where(user_id: params[:user_id]) if params[:user_id].present?
      ctx[:models] = user_courses.includes(
        :user_lesson_progresses,
        :user_quizzes,
        course: [{ lessons: :lesson_pages }, :quizzes]
      )
      ctx[:response_data] = {
        data: ctx[:models].map do |assignment|
          {
            id: assignment.id,
            user_id: assignment.user_id,
            course_id: assignment.course_id,
            status: assignment.status,
            progress_percentage: assignment.progress_percentage,
              resume_position: assignment.resume_position,
            course: {
              id: assignment.course.id,
              title: assignment.course.title,
                description: assignment.course.description,
                status: assignment.course.status,
                lessons: assignment.course.lessons.sort_by(&:position).map do |lesson|
                lesson_progress_payload(lesson, assignment)
                end,
                final_quiz: final_quiz_payload(assignment)
            }
          }
        end
      }
      true
    end

    def lesson_progress_payload(lesson, assignment)
      pages = lesson.lesson_pages.to_a
      progress = assignment.user_lesson_progresses.find { |item| item.lesson_id == lesson.id }
      quiz = assignment.course.quizzes.find do |item|
        item.quiz_type == "lesson" && item.lesson_id == lesson.id
      end
      attempts = quiz ? attempts_for(assignment, quiz) : []
      latest_attempt = attempts.max_by(&:attempt_number)
      calculation = Progress::LessonCalculator.call(
        lesson: lesson,
        progress: progress,
        quiz: quiz,
        quiz_passed: attempts.any? { |attempt| attempt.status == "submitted" && attempt.result == "pass" },
        quiz_attempted: attempts.any?
      )
      page_metadata = (progress&.metadata || {}).fetch("pages", {})

      {
        id: lesson.id,
        title: lesson.title,
        position: lesson.position,
        lesson_progress: {
          id: progress&.id,
          status: calculation[:status],
          completed_pages: calculation[:completed_pages],
          total_pages: calculation[:total_pages],
          progress_percentage: calculation[:progress_percentage],
          started_at: progress&.started_at,
          completed_at: progress&.completed_at
        },
        lesson_quiz: quiz && quiz_payload(quiz, latest_attempt),
        lesson_pages: pages.map do |page|
          page_data = page_metadata[page.id.to_s] || {}
          {
            id: page.id,
            title: page.title,
            topic: page.topic,
            position: page.position,
            content: page.content,
            metadata: page.metadata,
            user_lesson_progress: { completed: page_data["completed"] == true }
          }
        end
      }
    end

    def final_quiz_payload(assignment)
      quiz = assignment.course.quizzes.find do |item|
        item.quiz_type == "final" && item.lesson_id.nil?
      end
      return nil unless quiz

      latest_attempt = attempts_for(assignment, quiz).max_by(&:attempt_number)
      quiz_payload(quiz, latest_attempt, pending_until_submitted: true)
    end

    def quiz_payload(quiz, attempt, pending_until_submitted: false)
      submitted = attempt&.status == "submitted"
      {
        id: quiz.id,
        title: quiz.title,
        quiz_type: quiz.quiz_type,
        status: pending_until_submitted ? (submitted ? "submitted" : "pending") : (attempt&.status || "pending"),
        attempt_status: attempt&.status,
        attempt_number: attempt&.attempt_number,
        result: submitted ? attempt.result : nil,
        score: submitted ? attempt.score : nil,
        total_marks: submitted ? attempt.total_marks : nil,
        percentage: submitted ? attempt.percentage : nil,
        submitted_at: submitted ? attempt.submitted_at : nil
      }
    end

    def attempts_for(assignment, quiz)
      assignment.user_quizzes.select { |attempt| attempt.quiz_id == quiz.id }
    end
  end
end
