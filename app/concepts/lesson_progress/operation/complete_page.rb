# LessonProgress module
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

      ctx[:error] = {
        msg: "Course assignment not found",
        status: :not_found
      }
      false
    end

    def find_lesson_progress(ctx, lesson_id:, **)
      ctx[:lesson_progress] =
        ctx[:user_course].lesson_progresses.find_by(
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

    def complete_page(ctx, page_number:, **)
      progress = ctx[:lesson_progress]

      UserCourse.transaction do
        progress.with_lock do
          pages = progress.lesson.pages || []

          if pages.empty?
            ctx[:error] = {
              msg: "This lesson has no documentation pages",
              status: :unprocessable_entity
            }
            next false
          end

          requested_page = Integer(page_number.to_s, 10)

          if requested_page < 1 || requested_page > pages.size
            ctx[:error] = {
              msg: "Page does not exist",
              status: :unprocessable_entity
            }
            next false
          end

          expected_page = progress.completed_pages + 1

          if requested_page != expected_page
            ctx[:error] = {
              msg: "Invalid page. Complete page #{expected_page} first.",
              status: :unprocessable_entity
            }
            next false
          end

          progress.update!(
            completed_pages: progress.completed_pages + 1,
            total_pages: pages.size
          )

          Progress::Updater.call(
            user_course: ctx[:user_course]
          )

          true
        end
      end
    rescue ArgumentError, TypeError
      ctx[:error] = {
        msg: "Invalid page number",
        status: :unprocessable_entity
      }
      false
    rescue ActiveRecord::RecordInvalid => e
      ctx[:errors] = e.record.errors.full_messages
      ctx[:error] = {
        msg: "Unable to complete page",
        status: :unprocessable_entity
      }
      false
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Unable to complete page",
        status: :internal_server_error
      }
    end
  end
end
