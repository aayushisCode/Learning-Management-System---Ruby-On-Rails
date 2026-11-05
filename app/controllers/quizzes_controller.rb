
class QuizzesController < ApplicationController
  before_action :authenticate_user!

  # Admin-only quiz management
  before_action :require_admin!, only: [ :create, :update, :destroy ]

  # GET /quizzes
  # GET /courses/:course_id/quizzes
  def index
    result = Quiz::Operation::Index.call(params: params)

    if result.success?
      render json: result[:models].as_json(
        only: [
          :id, :course_id, :lesson_id, :title, :description,
          :quiz_type, :pass_marks, :created_at, :updated_at
        ]
      ), status: :ok
    else
      render json: { error: result[:error] },
             status: :internal_server_error
    end
  end

  # GET /quizzes/:id
  def show
    result = Quiz::Operation::Show.call(params: params)

    if result.success?
      render json: result[:model].as_json(
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
      ), status: :ok
    else
      render json: { error: result[:error] }, status: :not_found
    end
  end

  # POST /quizzes
  def create
    result = Quiz::Operation::Create.call(
      quiz_params: quiz_params
    )

    if result.success?
      render json: result[:model],
             status: :created
    else
      render json: {
        errors: result[:errors],
        error: result[:error]
      }, status: :unprocessable_entity
    end
  end

  # PATCH /quizzes/:id
  def update
    result = Quiz::Operation::Update.call(
      params: params,
      quiz_params: quiz_params
    )

    if result.success?
      render json: result[:model],
             status: :ok
    else
      status = result[:error]&.include?("not found") ?
                 :not_found : :unprocessable_entity

      render json: {
        errors: result[:errors],
        error: result[:error]
      }, status: status
    end
  end

  # DELETE /quizzes/:id
  def destroy
    result = Quiz::Operation::Destroy.call(params: params)

    if result.success?
      head :no_content
    else
      status = result[:error]&.include?("not found") ?
                 :not_found : :unprocessable_entity

      render json: {
        error: result[:error],
        errors: result[:errors]
      }, status: status
    end
  end

  # ==========================================
  # LEARNER QUIZ ATTEMPTS
  # ==========================================

  # POST /user_courses/:user_course_id/quizzes/:quiz_id/start
  def start
    result = UserQuiz::Operation::Start.call(
      current_user: current_user,
      params: params
    )

    if result.success?
      render json: {
        message: "Quiz started",
        user_quiz_id: result[:model].id,
        attempt_number: result[:model].attempt_number,
        started_at: result[:model].started_at
      }, status: :created
    else
      body = { error: result[:error] }
      body[:user_quiz_id] = result[:model].id if result[:model]

      render json: body, status: :unprocessable_entity
    end
  end

  # GET /user_quizzes/:id
  # View a learner's quiz attempt
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
    result = UserOption::Operation::Create.call(
      current_user: current_user,
      params: params,
      answer_params: answer_params
    )

    if result.success?
      render json: {
        message: "Answer recorded",
        user_option: result[:model].as_json(
          only: [ :id, :question_id, :option_id ]
        )
      }, status: :created
    else
      status = result[:error]&.include?("not found") ?
                 :not_found : :unprocessable_entity

      render json: {
        error: result[:error],
        errors: result[:errors]
      }, status: status
    end
  end

  # POST /user_quizzes/:id/submit
  def submit
    result = UserQuiz::Operation::Submit.call(
      current_user: current_user,
      params: params
    )

    if result.success?
      render json: {
        message: "Quiz submitted",
        score: result[:score],
        total_marks: result[:total_marks],
        percentage: result[:percentage],
        result: result[:result]
      }, status: :ok
    else
      status = result[:error]&.include?("not found") ?
                 :not_found : :unprocessable_entity

      render json: {
        error: result[:error],
        errors: result[:errors]
      }, status: status
    end
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
