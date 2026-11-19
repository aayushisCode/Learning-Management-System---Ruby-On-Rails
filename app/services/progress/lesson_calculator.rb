
module Progress
  class LessonCalculator
    def self.call(lesson:, progress:, quiz:, quiz_passed:, quiz_attempted:)
      pages = lesson.lesson_pages.to_a

      page_states = progress&.metadata&.fetch("pages", {}) || {}

      total_pages = pages.size

      completed_pages = pages.count do |page|
        page_state = page_states[page.id.to_s]
        page_state.is_a?(Hash) && page_state["completed"] == true
      end

      total_activities = total_pages + (quiz.present? ? 1 : 0)

      completed_activities =
        completed_pages + (quiz_passed ? 1 : 0)

      percentage =
        if total_activities.zero?
          0.0
        else
          (completed_activities.to_f / total_activities * 100).round(2)
        end

      status =
        if total_activities.positive? &&
           completed_activities == total_activities
          "completed"
        elsif completed_activities.positive? ||
              progress&.started_at.present? ||
              quiz_attempted
          "in_progress"
        else
          "not_started"
        end

      completed_at =
        if status == "completed"
          progress&.completed_at || Time.current
        else
          nil
        end

      {
        total_pages: total_pages,
        completed_pages: completed_pages,
        progress_percentage: percentage,
        status: status,
        completed_at: completed_at
      }
    end
  end
end





# module Progress
#   class LessonCalculator
#     def self.call(lesson:, user_course:)
#       progress = user_course.user_lesson_progresses.find_by(
#         lesson_id: lesson.id
#       )

#       pages = progress&.metadata&.fetch("pages", {}) || {}

#       total_pages = lesson.lesson_pages.count

#       completed_pages = pages.values.count do |page|
#         page["completed"] == true
#       end

#       quiz = Quiz.find_by(
#         course_id: user_course.course_id,
#         lesson_id: lesson.id,
#         quiz_type: "lesson"
#       )

#       quiz_passed = quiz.present? &&
#         UserQuiz.exists?(
#           user_course: user_course,
#           quiz: quiz,
#           status: "submitted",
#           result: "pass"
#         )

#       total_activities = total_pages + (quiz.present? ? 1 : 0)
#       completed_activities = completed_pages + (quiz_passed ? 1 : 0)

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
#           "not_started"
#         end

#       {
#         total_pages: total_pages,
#         completed_pages: completed_pages,
#         progress_percentage: percentage,
#         status: status
#       }
#     end
#   end
# end
