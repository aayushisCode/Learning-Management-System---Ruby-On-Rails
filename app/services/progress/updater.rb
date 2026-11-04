module Progress
  class Updater
    def self.call(user_course:)
      UserCourse.transaction do
        # Step 1: Calculate each lesson's progress
        user_course.lesson_progresses.each do |lesson_progress|
          attributes = Progress::LessonCalculator.call(
            lesson_progress: lesson_progress
          )

          lesson_progress.update!(attributes)
        end

        # Step 2: Reload updated lesson progress records
        user_course.lesson_progresses.reset

        # Step 3: Calculate overall course progress
        course_attributes = Progress::CourseCalculator.call(
          user_course: user_course
        )

        # Step 4: Update course assignment
        user_course.update!(course_attributes)
      end

      true
    end
  end
end
