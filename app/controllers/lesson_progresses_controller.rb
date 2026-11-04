class LessonProgressesController < ApplicationController
  def next_page
    result = LessonProgress::Operation::NextPage.call(
      current_user: current_user,
      user_course_id: params[:user_course_id],
      lesson_id: params[:lesson_id]
    )

    if result.success?
      render json: {
        page_number: result[:page_number],
        page: result[:page]
      }, status: :ok
    else
      render json: {
        error: result[:error]
      }, status: :unprocessable_entity
    end
  end

  def complete_page
    result = LessonProgress::Operation::CompletePage.call(
      current_user: current_user,
      user_course_id: params[:user_course_id],
      lesson_id: params[:lesson_id],
      page_number: params[:page_number]
    )

    if result.success?
      progress = result[:lesson_progress]
      course_progress = progress.user_course

      render json: {
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
    else
      render json: {
        error: result[:error]
      }, status: :unprocessable_entity
    end
  end
end
