
module LessonProgress::Operation
  class NextPage < Trailblazer::Operation
    step :find_assignment
    step :find_lesson_progress
    step :check_previous_lessons
    step :fetch_next_page

    fail :handle_failure

    def find_assignment(ctx, current_user:, user_course_id:, **)
      ctx[:user_course] = current_user.user_courses.find_by(
        id: user_course_id
      )

      return true if ctx[:user_course]

      ctx[:error] = {
        msg: "Course assignment not found",
        status: :not_found
      }
      false
    end

    def find_lesson_progress(ctx, lesson_id:, **)
      ctx[:lesson_progress] =
        ctx[:user_course].lesson_progresses.includes(:lesson).find_by(
          lesson_id: lesson_id
        )

      return true if ctx[:lesson_progress]

      ctx[:error] = {
        msg: "Lesson progress not found",
        status: :not_found
      }
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

      ctx[:error] = {
        msg: "Complete previous lessons first",
        status: :unprocessable_entity
      }
      false
    end

    def fetch_next_page(ctx, **)
      progress = ctx[:lesson_progress]
      pages = progress.lesson.pages || []

      if pages.empty?
        ctx[:error] = {
          msg: "This lesson has no documentation pages",
          status: :unprocessable_entity
        }
        return false
      end

      if progress.completed_pages >= pages.size
        ctx[:error] = {
          msg: "All documentation pages are completed",
          status: :unprocessable_entity
        }
        return false
      end

      ctx[:page_number] = progress.completed_pages + 1
      ctx[:page] = pages[progress.completed_pages]
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Unable to fetch the next page",
        status: :internal_server_error
      }
    end
  end
end
