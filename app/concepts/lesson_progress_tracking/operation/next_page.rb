
module LessonProgressTracking
  module Operation
    class NextPage < ApplicationOperation
      step :find_lesson
      step :check_previous_lessons
      step :complete_current_page
      step :fetch_next_page

      def find_lesson(ctx, user_course:, lesson_id:, **)
        ctx[:lesson] = user_course.course.lessons
                                      .includes(:lesson_pages)
                                      .find_by(id: lesson_id)

        return true if ctx[:lesson]

        ctx[:error] = {
          msg: "Lesson not found",
          status: :not_found
        }

        false
      end

      def check_previous_lessons(ctx, user_course:, lesson:, **)
        previous_lessons = user_course.course.lessons
                                      .where("position < ?", lesson.position)

        incomplete_lesson = previous_lessons.any? do |previous_lesson|
          result = Progress::LessonCalculator.call(
            lesson: previous_lesson,
            user_course: user_course
          )

          result[:status] != "completed"
        end

        return true unless incomplete_lesson

        ctx[:error] = {
          msg: "Complete previous lessons first",
          status: :unprocessable_entity
        }

        false
      end

      def complete_current_page(ctx, user_course:, lesson:, page_number:, **)
        # First request: return the first page without completing anything.
        return true if page_number.blank?

        pages = lesson.lesson_pages.order(:position).to_a
        current_page = pages[page_number.to_i - 1]

        unless current_page
          ctx[:error] = {
            msg: "Invalid page number",
            status: :unprocessable_entity
          }
          return false
        end

        progress = user_course.user_lesson_progresses.find_or_initialize_by(
          lesson_id: lesson.id
        )

        progress.metadata ||= {}
        metadata = progress.metadata.deep_dup
        metadata["pages"] ||= {}

        page_key = current_page.id.to_s

        # Enforce sequential completion.
        previous_page = pages[page_number.to_i - 2] if page_number.to_i > 1

        if previous_page &&
           metadata.dig("pages", previous_page.id.to_s, "completed") != true

          ctx[:error] = {
            msg: "Complete previous page first",
            status: :unprocessable_entity
          }

          return false
        end

        metadata["pages"][page_key] = {
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
          if total_pages.zero?
            0
          else
            (completed_pages.to_f / total_pages * 100).round(2)
          end

        progress.metadata = metadata
        progress.save!

        # Recalculate course progress, including quiz completion.
        Progress::Updater.call(user_course: user_course)

        true
      end

      def fetch_next_page(ctx, lesson:, page_number:, **)
        pages = lesson.lesson_pages.order(:position).to_a

        next_index =
          if page_number.blank?
            0
          else
            page_number.to_i
          end

        next_page = pages[next_index]

        unless next_page
          ctx[:error] = {
            msg: "No more pages available",
            status: :not_found
          }
          return false
        end

        ctx[:page_number] = next_index + 1
        ctx[:page] = next_page

        true
      end
    end
  end
end
