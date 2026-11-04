module Progress
  class LessonCalculator
    def self.call(lesson_progress:)
      total_pages = lesson_progress.total_pages
      completed_pages = lesson_progress.completed_pages

      # Find the lesson quiz, if one exists
      quiz = Quiz.find_by(
        course_id: lesson_progress.user_course.course_id,
        lesson_id: lesson_progress.lesson_id,
        quiz_type: "lesson"
      )

      # Check whether the learner passed the quiz
      quiz_passed =
        quiz.present? &&
        UserQuiz.exists?(
          user_course: lesson_progress.user_course,
          quiz: quiz,
          status: "submitted",
          result: "pass"
        )

      # Count the quiz as one learning activity
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
        status: status,
        completed_at: if status == "completed"
                        lesson_progress.completed_at || Time.current
                      end
      }
    end
  end
end
