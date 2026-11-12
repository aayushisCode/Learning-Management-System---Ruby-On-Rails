module Progress
  class Updater
    def self.call(user_course:)
      UserCourse.transaction do
        course_attributes = Progress::CourseCalculator.call(
          user_course: user_course
        )

        user_course.update!(course_attributes)
      end

      true
    end
  end
end