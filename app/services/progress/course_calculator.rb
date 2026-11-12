module Progress
  class CourseCalculator
    def self.call(user_course:)
      course = user_course.course
      lessons = course.lessons.to_a

      total_lessons = lessons.size

      lesson_results = lessons.map do |lesson|
        Progress::LessonCalculator.call(
          lesson: lesson,
          user_course: user_course
        )
      end

      completed_lessons = lesson_results.count do |result|
        result[:status] == "completed"
      end

      total_pages = course.lesson_pages.count

      completed_pages = user_course.user_lesson_progresses
        .joins(:lesson_page)
        .where(
          lesson_pages: { lesson_id: lessons.map(&:id) },
          user_lesson_progresses: { status: "completed" }
        )
        .count

      lesson_quizzes = Quiz.where(
        course_id: course.id,
        lesson_id: lessons.map(&:id),
        quiz_type: "lesson"
      )

      final_quiz = Quiz.find_by(
        course_id: course.id,
        quiz_type: "final",
        lesson_id: nil
      )

      quiz_ids = lesson_quizzes.pluck(:id)
      quiz_ids << final_quiz.id if final_quiz.present?

      passed_quiz_ids = UserQuiz.where(
        user_course_id: user_course.id,
        quiz_id: quiz_ids,
        status: "submitted",
        result: "pass"
      ).distinct.pluck(:quiz_id)

      total_quizzes = quiz_ids.size
      completed_quizzes = passed_quiz_ids.size

      total_activities = total_pages + total_quizzes
      completed_activities = completed_pages + completed_quizzes

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
          "assigned"
        end

      {
        total_lessons: total_lessons,
        completed_lessons: completed_lessons,
        progress_percentage: percentage,
        status: status,
        completed_at: status == "completed" ?
          (user_course.completed_at || Time.current) : nil
      }
    end
  end
end