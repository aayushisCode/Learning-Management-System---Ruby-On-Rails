
module LessonProgressTracking
  module Operation
    class NavigatePage < ApplicationOperation
      step :find_user_course
      step :find_lesson
      step :fetch_pages
      step :navigate

      def find_user_course(ctx, params:, **)
        user_course = policy_scope_for(ctx, UserCourse).find_by(id: params[:user_course_id])
        unless user_course
          ctx[:error] = { msg: "Assignment not found", status: :not_found }
          return false
        end

        authorize_record(ctx, user_course, :navigate_page?, policy_class: UserLessonProgressPolicy)
        ctx[:user_course] = user_course
      end

      def find_lesson(ctx, params:, user_course:, **)
        ctx[:lesson] = user_course.course.lessons
                                  .includes(:lesson_pages)
                                  .find_by(id: params[:id])

        return true if ctx[:lesson]

        ctx[:error] = {
          msg: "Lesson not found",
          status: :not_found
        }

        false
      end

      def fetch_pages(ctx, lesson:, **)
        ctx[:pages] = lesson.lesson_pages.order(:position).to_a

        return true if ctx[:pages].any?

        ctx[:error] = {
          msg: "This lesson has no pages",
          status: :not_found
        }

        false
      end

      def navigate(ctx, params:, user_course:, lesson:, pages:, **)
        page_number = params[:page_number]
        direction = params[:direction]
        # Initial request: fetch page 1 without completing it.
        if page_number.blank?
          ctx[:page_number] = 1
          ctx[:page] = pages.first
          save_resume_position(user_course, lesson, ctx[:page_number])
          return true
        end

        current_number = Integer(page_number) rescue nil

        unless current_number && current_number.between?(1, pages.size)
          ctx[:error] = {
            msg: "Invalid page number",
            status: :unprocessable_entity
          }
          return false
        end

        current_index = current_number - 1

        # BACKWARD NAVIGATION
        if direction == "backward"

          if current_number == 1
            ctx[:error] = {
              msg: "You are already on the first page",
              status: :unprocessable_entity
            }
            return false
          end

          ctx[:page_number] = current_number - 1
          ctx[:page] = pages[current_index - 1]
          save_resume_position(user_course, lesson, ctx[:page_number])

          return true
        end

        # FORWARD NAVIGATION
        unless direction == "forward"
          ctx[:error] = {
            msg: "Invalid navigation direction",
            status: :unprocessable_entity
          }
          return false
        end

        progress = user_course.user_lesson_progresses
                             .find_or_initialize_by(lesson_id: lesson.id)

        metadata = (progress.metadata || {}).deep_dup
        metadata["pages"] ||= {}

        # Initialize missing page progress entries.
        pages.each do |page|
          metadata["pages"][page.id.to_s] ||= {
            "completed" => false
          }
        end

        # Enforce sequential completion.
        previous_pages = pages.first(current_index)

        incomplete_page = previous_pages.any? do |page|
          metadata.dig("pages", page.id.to_s, "completed") != true
        end

        if incomplete_page
          ctx[:error] = {
            msg: "Complete previous pages first",
            status: :unprocessable_entity
          }
          return false
        end

        # Complete the current page.
        current_page = pages[current_index]

        metadata["pages"][current_page.id.to_s] = {
          "completed" => true,
          "completed_at" => Time.current
        }

        completed_pages = metadata["pages"].values.count do |page|
          page["completed"] == true
        end

        total_pages = pages.size

        metadata["completed_pages"] = completed_pages
        metadata["total_pages"] = total_pages
        metadata["progress_percentage"] =
          (completed_pages.to_f / total_pages * 100).round(2)

        # Set started_at only once
        progress.started_at ||= Time.current

        # Update lesson status and completion timestamp
        if completed_pages == total_pages
        progress.status = "completed"
        progress.completed_at ||= Time.current
        else
        progress.status = "in_progress"
        end

        progress.metadata = metadata

        unless progress.save
        ctx[:error] = {
            msg: progress.errors.full_messages,
            status: :unprocessable_entity
        }
        return false
        end

        # Recalculate course progress.
        Progress::Updater.call(user_course: user_course)

        # Check whether another page exists.
        next_page = pages[current_index + 1]

        if next_page
          ctx[:page_number] = current_number + 1
          ctx[:page] = next_page
          save_resume_position(user_course, lesson, ctx[:page_number])
          return true
        end

        # No next page: lesson completed.
        save_resume_position(user_course, lesson, current_number)
        ctx[:lesson_completed] = true
        ctx[:message] = "Your lesson is completed"

        true
      end

      def save_resume_position(user_course, lesson, page_number)
        user_course.save_resume_position(
          lesson: lesson,
          page_number: page_number
        )
      end
    end
  end
end
