module LessonProgress::Operation
  class CompletePage < Trailblazer::Operation
    step :find_assignment
    step :find_lesson_progress
    step :check_previous_lessons
    step :complete_page

    fail :handle_failure

    def find_assignment(ctx, current_user:, user_course_id:, **)
      ctx[:user_course] = current_user.user_courses.find_by(
        id: user_course_id
      )

      return true if ctx[:user_course]

      ctx[:error] = "Course assignment not found"
      false
    end

    def find_lesson_progress(ctx, lesson_id:, **)
      ctx[:lesson_progress] =
        ctx[:user_course].lesson_progresses.find_by(
          lesson_id: lesson_id
        )

      return true if ctx[:lesson_progress]

      ctx[:error] = "Lesson progress not found"
      false
    end

    def check_previous_lessons(ctx, **)
      progress = ctx[:lesson_progress]

      previous_incomplete = ctx[:user_course]
        .lesson_progresses
        .joins(:lesson)
        .where("lessons.position < ?", progress.lesson.position)
        .where.not(status: "completed")
        .exists?

      return true unless previous_incomplete

      ctx[:error] = "Complete previous lessons first"
      false
    end

    def complete_page(ctx, page_number:, **)
      progress = ctx[:lesson_progress]

      UserCourse.transaction do
        result = progress.with_lock do
          pages = progress.lesson.pages || []

          if pages.empty?
            ctx[:error] = "This lesson has no documentation pages"
            next false
          end

          requested_page = Integer(page_number.to_s, 10)

          if requested_page < 1 || requested_page > pages.size
            ctx[:error] = "Page does not exist"
            next false
          end

          expected_page = progress.completed_pages + 1

          if requested_page != expected_page
            ctx[:error] =
              "Invalid page. Complete page #{expected_page} first."
            next false
          end

          progress.update!(
            completed_pages: progress.completed_pages + 1,
            total_pages: pages.size
          )

          # Recalculate lesson and course progress
          Progress::Updater.call(
            user_course: ctx[:user_course]
          )

          true
        end

        result
      end
    rescue ArgumentError, TypeError
      ctx[:error] = "Invalid page number"
      false
    rescue ActiveRecord::RecordInvalid => e
      ctx[:error] = e.record.errors.full_messages
      false
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "Unable to complete page"
    end
  end
end
