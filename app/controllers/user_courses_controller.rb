class UserCoursesController < ApplicationController
  before_action :authenticate_user!

  # GET /user_courses
  # Admin → all, Manager → their assignments, Learner → own enrollments
  def index
    result = UserCourse::Operation::Index.call(
      current_user: current_user,
      params: params
    )

    if result.success?
      render json: result[:models].as_json(
        only: [ :id, :user_id, :course_id, :assigned_by_id, :status, :assigned_at,
                :due_date, :completed_at, :progress_percentage,
                :completed_lessons, :total_lessons, :created_at, :updated_at ]
      ), status: :ok
    else
      render json: { error: result[:error] }, status: :internal_server_error
    end
  end

  # GET /user_courses/:id  — with lesson + quiz progress detail
  def show
    result = UserCourse::Operation::Show.call(
      params: params,
      current_user: current_user
    )

    if result.success?
      uc = result[:model]
      render json: {
        id:                  uc.id,
        user_id:             uc.user_id,
        course_id:           uc.course_id,
        assigned_by_id:      uc.assigned_by_id,
        status:              uc.status,
        progress_percentage: uc.progress_percentage,
        completed_lessons:   uc.completed_lessons,
        total_lessons:       uc.total_lessons,
        assigned_at:         uc.assigned_at,
        due_date:            uc.due_date,
        completed_at:        uc.completed_at,
        lesson_progresses:   uc.lesson_progresses.as_json(
          only: [ :id, :lesson_id, :status, :completed_pages, :total_pages,
                  :progress_percentage, :started_at, :completed_at ]
        ),
        quiz_attempts:       uc.user_quizzes.as_json(
          only: [ :id, :quiz_id, :attempt_number, :score, :total_marks,
                  :percentage, :status, :result, :started_at, :submitted_at ]
        )
      }, status: :ok
    else
      status = result[:error]&.include?("not found") ? :not_found : :forbidden
      render json: { error: result[:error] }, status: status
    end
  end

  # POST /user_courses  — bulk assign: admin/manager only
  def create
    authorize!("admin", "manager")
    return if performed?

    result = UserCourse::Operation::Create.call(
      user_course_params: user_course_params,
      current_user: current_user
    )

    if result.success?
      render json: {
        message:     "Course(s) assigned successfully",
        assignments: result[:assignments].as_json(
          only: [ :id, :user_id, :course_id, :status, :assigned_at ]
        )
      }, status: :created
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  # DELETE /user_courses/:id  — admin or assigning manager only
  def destroy
    result = UserCourse::Operation::Destroy.call(
      params: params,
      current_user: current_user
    )

    if result.success?
      head :no_content
    else
      status = result[:error]&.include?("not found") ? :not_found : :forbidden
      render json: { error: result[:error] }, status: status
    end
  end

  private

  def user_course_params
    params.require(:user_course).permit(
      :filter_type, :category_id,
      course_ids: [],
      user_ids:   [],
      role_ids:   []
    ).to_h.with_indifferent_access
  end
end
