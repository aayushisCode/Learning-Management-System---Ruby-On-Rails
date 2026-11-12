
class UserCoursesController < ApplicationController
  before_action :authenticate_user!

  # GET /user_courses

  def index
    result = run UserCourse::Operation::Index,
                    current_user: current_user,
                    params: params do |result|
      data = result[:models].map do |uc|
        {
          id: uc.id,
          user_id: uc.user_id,
          course_id: uc.course_id,
          status: uc.status,
          progress_percentage: uc.progress_percentage,

          course: {
            id: uc.course.id,
            title: uc.course.title,

            lessons: uc.course.lessons.map do |lesson|
              progress = uc.lesson_progresses.find {
                |lp| lp.lesson_id == lesson.id
              }

              {
                id: lesson.id,
                title: lesson.title,
                position: lesson.position,

                lesson_progress: progress&.as_json(
                  only: [
                    :id, :status, :completed_pages,
                    :total_pages, :progress_percentage,
                    :started_at, :completed_at
                  ]
                )
              }
            end
          }
        }
      end

      return render json: { data: data }, status: :ok
    end

    render_operation_error(
      result,
      default_status: :internal_server_error
    )
  end


  # GET /user_courses/:id

  def show
    result = run UserCourse::Operation::Show,
                  params: params,
                  current_user: current_user do |result|
      uc = result[:model]

      return render json: {
        id: uc.id,
        user_id: uc.user_id,
        course_id: uc.course_id,
        assigned_by_id: uc.assigned_by_id,
        status: uc.status,

        progress_percentage: uc.progress_percentage,
        completed_lessons: uc.completed_lessons,
        total_lessons: uc.total_lessons,

        assigned_at: uc.assigned_at,
        due_date: uc.due_date,
        completed_at: uc.completed_at,

        course: {
          id: uc.course.id,
          title: uc.course.title,

          lessons: uc.course.lessons.map do |lesson|
            progress = uc.lesson_progresses.find {
              |lp| lp.lesson_id == lesson.id
            }

            {
              id: lesson.id,
              title: lesson.title,
              position: lesson.position,

              lesson_progress: progress&.as_json(
                only: [
                  :id, :status, :completed_pages,
                  :total_pages, :progress_percentage,
                  :started_at, :completed_at
                ]
              )
            }
          end
        },

        quiz_attempts: uc.user_quizzes.as_json(
          only: [
            :id, :quiz_id, :attempt_number, :score,
            :total_marks, :percentage, :status,
            :result, :started_at, :submitted_at
          ]
        )
      }, status: :ok
    end

    render_operation_error(result, default_status: :not_found)
  end


  # POST /user_courses
  def create
    return unless authorize_roles!("admin", "manager")

    result = run UserCourse::Operation::Create do |result|
      return render json: {
        message: "Course(s) assigned successfully",
        assignments: result[:assignments].as_json(
          only: [
            :id, :user_id, :course_id, :status, :assigned_at
          ]
        )
      }, status: :created
    end

    render_operation_error(result)
  end

  # DELETE /user_courses/:id
  def destroy
    result = run UserCourse::Operation::Destroy,
                  with: {
                    params: params,
                    current_user: current_user
                  } do |_result|
      return head :no_content
    end

    render_operation_error(result, default_status: :not_found)
  end

  private

  def user_course_params
    params.require(:user_course).permit(
      :filter_type,
      :category_id,
      :course_id,
      user_ids: [],
      role_ids: []
    ).to_h.with_indifferent_access
  end
end
