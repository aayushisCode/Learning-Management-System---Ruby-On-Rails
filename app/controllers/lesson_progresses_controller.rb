# Lesson Progresses Controller
class LessonProgressesController < ApplicationController
  # GET /lesson_progresses/next_page
  def next_page
    result = run LessonProgress::Operation::NextPage,
                  with: {
                    current_user: current_user,
                    user_course_id: params[:user_course_id],
                    lesson_id: params[:lesson_id]
                  } do |result|
      return render json: {
        page_number: result[:page_number],
        page: result[:page]
      }, status: :ok
    end

    render json: {
      error: result[:error][:msg]
    }, status: result[:error][:code]
  end

  # POST /lesson_progresses/complete_page
  def complete_page
    result = run LessonProgress::Operation::CompletePage,
                  with: {
                    current_user: current_user,
                    user_course_id: params[:user_course_id],
                    lesson_id: params[:lesson_id],
                    page_number: params[:page_number]
                  } do |result|
      progress = result[:lesson_progress]
      course_progress = progress.user_course

      return render json: {
        message: "Page completed successfully",

        lesson: {
          completed_pages: progress.completed_pages,
          total_pages: progress.total_pages,
          progress_percentage: progress.progress_percentage,
          status: progress.status
        },

        course: {
          progress_percentage: course_progress.progress_percentage,
          completed_lessons: course_progress.completed_lessons,
          total_lessons: course_progress.total_lessons,
          status: course_progress.status
        }
      }, status: :ok
    end

    render json: {
      error: result[:error][:msg]
    }, status: result[:error][:code]
  end

  def prev_page
    result = run LessonProgress::Operation::PrevPage,
                with: {
                  current_user: current_user,
                  user_course_id: params[:user_course_id],
                  lesson_id: params[:lesson_id]
                } do |result|
      return render json: {
        page_number: result[:page_number],
        page: result[:page]
      }, status: :ok
    end

    render_operation_error(result)
  end
end
