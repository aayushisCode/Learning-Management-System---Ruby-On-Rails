
module LessonProgressTracking
  module Operation
    class PrevPage < ApplicationOperation
      step :find_lesson
      step :fetch_previous_page

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

      def fetch_previous_page(ctx, lesson:, page_number:, **)
        pages = lesson.lesson_pages.order(:position).to_a

        previous_index = page_number.to_i - 2

        unless previous_index >= 0 && pages[previous_index]
          ctx[:error] = {
            msg: "No previous page available",
            status: :not_found
          }
          return false
        end

        ctx[:page_number] = previous_index + 1
        ctx[:page] = pages[previous_index]

        true
      end
    end
  end
end
