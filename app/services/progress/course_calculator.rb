module Progress
  class CourseCalculator
    def self.call(user_course:)
      lesson_progresses = user_course.lesson_progresses.to_a

      total_lessons = lesson_progresses.size

      completed_lessons = lesson_progresses.count do |progress|
        progress.status == "completed"
      end

      # Calculate page activities
      total_pages = lesson_progresses.sum(&:total_pages)
      completed_pages = lesson_progresses.sum(&:completed_pages)

      # Find lesson quizzes configured for this course
      lesson_ids = lesson_progresses.map(&:lesson_id)

      lesson_quizzes = Quiz.where(
        course_id: user_course.course_id,
        lesson_id: lesson_ids,
        quiz_type: "lesson"
      )

      # Find the final quiz, if configured
      final_quiz = Quiz.find_by(
        course_id: user_course.course_id,
        quiz_type: "final",
        lesson_id: nil
      )

      # Find all successfully passed quizzes
      passed_quiz_ids = UserQuiz.where(
        user_course_id: user_course.id,
        status: "submitted",
        result: "pass"
      ).pluck(:quiz_id)

      # Calculate quiz activities
      total_quizzes = lesson_quizzes.count + (final_quiz.present? ? 1 : 0)

      completed_quizzes = lesson_quizzes.count do |quiz|
        passed_quiz_ids.include?(quiz.id)
      end

      if final_quiz.present? && passed_quiz_ids.include?(final_quiz.id)
        completed_quizzes += 1
      end

      # Calculate overall course progress
      total_activities = total_pages + total_quizzes
      completed_activities = completed_pages + completed_quizzes

      percentage =
        if total_activities.zero?
          0
        else
          (completed_activities.to_f / total_activities * 100).round(2)
        end

      # Determine course status
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
        completed_at: status == "completed" ? (user_course.completed_at || Time.current) : nil
      }
    end
  end
end
