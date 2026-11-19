module Progress
  class Updater
    def self.call(user_course:)
      UserCourse.transaction do
        result = Progress::CourseCalculator.call(
          user_course: user_course
        )

        lesson_progresses = result.delete(:lesson_progresses)

        # Save individual lesson progress
        lesson_progresses.each do |lesson_result|
          progress = UserLessonProgress.find_or_initialize_by(
            user_course_id: user_course.id,
            lesson_id: lesson_result[:lesson_id]
          )

          progress.update!(
            status: lesson_result[:status],
            progress_percentage: lesson_result[:progress_percentage],
            completed_at: lesson_result[:completed_at]
          )
        end

        # Save overall course progress
        user_course.update!(result)
      end

      true
    end
  end
end












# module Progress
#   class Updater
#     def self.call(user_course:)
#       UserCourse.transaction do
#         course_attributes = Progress::CourseCalculator.call(
#           user_course: user_course
#         )

#         user_course.update!(course_attributes)
#       end

#       true
#     end
#   end
# end
