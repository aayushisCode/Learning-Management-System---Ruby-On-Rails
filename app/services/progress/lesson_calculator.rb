module Progress
  class LessonCalculator
    def self.call(lesson:, user_course:)
      total_pages = lesson.lesson_pages.count

      completed_pages = user_course.user_lesson_progresses
        .joins(:lesson_page)
        .where(
          lesson_pages: { lesson_id: lesson.id },
          user_lesson_progresses: { status: "completed" }
        )
        .count

      quiz = Quiz.find_by(
        course_id: user_course.course_id,
        lesson_id: lesson.id,
        quiz_type: "lesson"
      )

      quiz_passed = quiz.present? &&
        UserQuiz.exists?(
          user_course: user_course,
          quiz: quiz,
          status: "submitted",
          result: "pass"
        )

      total_activities = total_pages + (quiz.present? ? 1 : 0)
      completed_activities = completed_pages + (quiz_passed ? 1 : 0)

      percentage =
        if total_activities.zero?
          0
        else
          (completed_activities.to_f / total_activities * 100).round(2)
        end

      status =
        if total_activities.positive? &&
           completed_activities >= total_activities
          "completed"
        elsif completed_activities.positive?
          "in_progress"
        else
          "not_started"
        end

      {
        total_pages: total_pages,
        completed_pages: completed_pages,
        progress_percentage: percentage,
        status: status
      }
    end
  end
end