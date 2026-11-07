
class QuizzesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, only: [ :create, :update, :destroy ]

  # GET /quizzes
  # GET /courses/:course_id/quizzes
  def index
    result = run Quiz::Operation::Index,
                  with: { params: params } do |result|
      return render json: {
        data: result[:models].as_json(
          only: [
            :id, :course_id, :lesson_id, :title, :description,
            :quiz_type, :pass_marks, :created_at, :updated_at
          ]
        )
      }, status: :ok
    end

    render_operation_error(result, default_status: :internal_server_error)
  end

  # GET /quizzes/:id
  def show
    result = run Quiz::Operation::Show,
                  with: { params: params } do |result|
      return render json: {
        data: result[:model].as_json(
          only: [
            :id, :course_id, :lesson_id, :title, :description,
            :quiz_type, :pass_marks, :created_at, :updated_at
          ],
          include: {
            questions: {
              only: [
                :id, :question_text, :question_type,
                :marks, :position, :status
              ],
              include: {
                options: {
                  only: [ :id, :option_text, :position ]
                }
              }
            }
          }
        )
      }, status: :ok
    end

    render_operation_error(result, default_status: :not_found)
  end

  # POST /quizzes
  def create
    result = run Quiz::Operation::Create,
                  with: { quiz_params: quiz_params } do |result|
      return render json: {
        data: result[:model]
      }, status: :created
    end

    render_operation_error(result)
  end

  # PATCH /quizzes/:id
  def update
    result = run Quiz::Operation::Update,
                  with: {
                    params: params,
                    quiz_params: quiz_params
                  } do |result|
      return render json: {
        data: result[:model]
      }, status: :ok
    end

    render_operation_error(result)
  end

  # DELETE /quizzes/:id
  def destroy
    result = run Quiz::Operation::Destroy,
                  with: { params: params } do |_result|
      return head :no_content
    end

    render_operation_error(result, default_status: :not_found)
  end

  # ==========================================
  # LEARNER QUIZ ATTEMPTS
  # ==========================================

  # POST /user_courses/:user_course_id/quizzes/:quiz_id/start
  def start
    result = run UserQuiz::Operation::Start,
                  with: {
                    current_user: current_user,
                    params: params
                  } do |result|
      return render json: {
        message: "Quiz started",
        user_quiz_id: result[:model].id,
        attempt_number: result[:model].attempt_number,
        started_at: result[:model].started_at
      }, status: :created
    end

    body = { error: result[:error] }

    body[:user_quiz_id] = result[:model].id if result[:model]

    render json: body,
           status: result[:error].is_a?(Hash) ?
             result[:error][:code] : :unprocessable_entity
  end

  # GET /user_quizzes/:id
  # View a learner's quiz attempt
  #
  # NOTE: This action currently has no Trailblazer operation.
  # Keep its existing implementation until an Attempt operation is created.
  def attempt
    attempt = UserQuiz.includes(
      :quiz,
      user_options: [ :question, :option ]
    ).find_by(id: params[:id])

    unless attempt
      return render json: {
        error: "Quiz attempt not found"
      }, status: :not_found
    end

    uc = attempt.user_course

    unless current_user.admin? ||
           uc.user_id == current_user.id ||
           uc.assigned_by_id == current_user.id

      return render json: {
        error: "Forbidden"
      }, status: :forbidden
    end

    render json: {
      id: attempt.id,
      quiz_id: attempt.quiz_id,
      user_course_id: attempt.user_course_id,
      attempt_number: attempt.attempt_number,
      status: attempt.status,
      result: attempt.result,
      score: attempt.score,
      total_marks: attempt.total_marks,
      percentage: attempt.percentage,
      started_at: attempt.started_at,
      submitted_at: attempt.submitted_at,
      answers: attempt.user_options.as_json(
        only: [ :id, :question_id, :option_id ]
      )
    }, status: :ok
  end

  # POST /user_quizzes/:id/answer
  def answer
    result = run UserOption::Operation::Create,
                  with: {
                    current_user: current_user,
                    params: params,
                    answer_params: answer_params
                  } do |result|
      return render json: {
        message: "Answer recorded",
        user_option: result[:model].as_json(
          only: [ :id, :question_id, :option_id ]
        )
      }, status: :created
    end

    render_operation_error(result)
  end

  # POST /user_quizzes/:id/submit
  def submit
    result = run UserQuiz::Operation::Submit,
                  with: {
                    current_user: current_user,
                    params: params
                  } do |result|
      return render json: {
        message: "Quiz submitted",
        score: result[:score],
        total_marks: result[:total_marks],
        percentage: result[:percentage],
        result: result[:result]
      }, status: :ok
    end

    render_operation_error(result)
  end

  private

  def require_admin!
    authorize!("admin")
  end

  def quiz_params
    merged = params.expect(
      quiz: [
        :course_id, :lesson_id, :title,
        :description, :quiz_type, :pass_marks
      ]
    )

    merged[:course_id] ||= params[:course_id] if params[:course_id].present?

    merged
  end

  def answer_params
    params.expect(
      answer: [ :question_id, :option_id ]
    )
  end
end
