
module Progress
  class CourseCalculator
    def self.call(user_course:)
      course = user_course.course

      lessons = course.lessons
                      .includes(:lesson_pages)
                      .order(:position)
                      .to_a

      progress_records = UserLessonProgress
                           .where(user_course_id: user_course.id)
                           .index_by(&:lesson_id)

      lesson_quizzes = course.quizzes
                             .where(quiz_type: "lesson")
                             .index_by(&:lesson_id)

      final_quiz = course.quizzes.find_by(
        quiz_type: "final",
        lesson_id: nil
      )

      all_quizzes = lesson_quizzes.values + [final_quiz].compact

      quiz_ids = all_quizzes.map(&:id)

      user_quiz_records = UserQuiz.where(
        user_course_id: user_course.id,
        quiz_id: quiz_ids
      ).to_a

      passed_quiz_ids = user_quiz_records
                          .select do |attempt|
                            attempt.status == "submitted" &&
                              attempt.result == "pass"
                          end
                          .map(&:quiz_id)
                          .uniq

      attempted_quiz_ids = user_quiz_records
                             .map(&:quiz_id)
                             .uniq

      # Calculate progress for every lesson
      lesson_results = lessons.map do |lesson|
        quiz = lesson_quizzes[lesson.id]

        Progress::LessonCalculator.call(
          lesson: lesson,
          progress: progress_records[lesson.id],
          quiz: quiz,
          quiz_passed: quiz.present? &&
                       passed_quiz_ids.include?(quiz.id),
          quiz_attempted: quiz.present? &&
                          attempted_quiz_ids.include?(quiz.id)
        ).merge(lesson_id: lesson.id)
      end

      # Calculate total and completed pages
      total_pages = lessons.sum do |lesson|
        lesson.lesson_pages.size
      end

      completed_pages = lesson_results.sum do |result|
        result[:completed_pages]
      end

      # Calculate total and passed quizzes
      total_quizzes = all_quizzes.size

      completed_quizzes = passed_quiz_ids.count do |quiz_id|
        quiz_ids.include?(quiz_id)
      end

      # Equal weightage: one page = one quiz
      total_activities = total_pages + total_quizzes

      completed_activities = completed_pages + completed_quizzes

      percentage =
        if total_activities.zero?
          0.0
        else
          (completed_activities.to_f / total_activities * 100).round(2)
        end

      completed_lessons = lesson_results.count do |result|
        result[:status] == "completed"
      end

      has_started =
        progress_records.values.any? do |progress|
          progress.started_at.present? ||
            progress.status == "in_progress"
        end || user_quiz_records.any?

      status =
        if total_activities.positive? &&
           completed_activities == total_activities
          "completed"
        elsif completed_activities.positive? || has_started
          "in_progress"
        else
          "assigned"
        end

      {
        total_lessons: lessons.size,
        completed_lessons: completed_lessons,
        progress_percentage: percentage,
        status: status,
        completed_at: status == "completed" ?
          (user_course.completed_at || Time.current) : nil,

        # Internal data for Updater
        lesson_progresses: lesson_results
      }
    end
  end
end























# module Progress
#   class CourseCalculator
#     def self.call(user_course:)
#       course = user_course.course
#       lessons = course.lessons.includes(:lesson_pages).to_a

#       total_lessons = lessons.size

#       lesson_results = lessons.map do |lesson|
#         Progress::LessonCalculator.call(
#           lesson: lesson,
#           user_course: user_course
#         )
#       end

#       completed_lessons = lesson_results.count do |result|
#         result[:status] == "completed"
#       end

#       total_pages = lessons.sum do |lesson|
#         lesson.lesson_pages.size
#       end

#       completed_pages = lessons.sum do |lesson|
#         progress = user_course.user_lesson_progresses.find do |item|
#           item.lesson_id == lesson.id
#         end

#         pages = progress&.metadata&.fetch("pages", {}) || {}

#         pages.values.count do |page|
#           page["completed"] == true
#         end
#       end

#       lesson_quizzes = Quiz.where(
#         course_id: course.id,
#         lesson_id: lessons.map(&:id),
#         quiz_type: "lesson"
#       )

#       final_quiz = Quiz.find_by(
#         course_id: course.id,
#         quiz_type: "final",
#         lesson_id: nil
#       )

#       quiz_ids = lesson_quizzes.pluck(:id)
#       quiz_ids << final_quiz.id if final_quiz.present?

#       passed_quiz_ids = UserQuiz.where(
#         user_course_id: user_course.id,
#         quiz_id: quiz_ids,
#         status: "submitted",
#         result: "pass"
#       ).distinct.pluck(:quiz_id)

#       total_quizzes = quiz_ids.size
#       completed_quizzes = passed_quiz_ids.size

#       total_activities = total_pages + total_quizzes
#       completed_activities = completed_pages + completed_quizzes

#       percentage =
#         if total_activities.zero?
#           0
#         else
#           (completed_activities.to_f / total_activities * 100).round(2)
#         end

#       status =
#         if total_activities.positive? &&
#            completed_activities >= total_activities
#           "completed"
#         elsif completed_activities.positive?
#           "in_progress"
#         else
#           "assigned"
#         end

#       {
#         total_lessons: total_lessons,
#         completed_lessons: completed_lessons,
#         progress_percentage: percentage,
#         status: status,
#         completed_at: status == "completed" ?
#           (user_course.completed_at || Time.current) : nil
#       }
#     end
#   end
# end
