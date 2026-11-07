
class UsersController < ApplicationController
  # GET /users
  def index
    result = run User::Operation::Index do |result|
      return render json: {
        data: result[:models].as_json(
          only: [
            :id, :email, :role_id, :created_at, :updated_at
          ]
        )
      }, status: :ok
    end

    render_operation_error(result, default_status: :internal_server_error)
  end

  # GET /users/:id
  def show
    result = run User::Operation::Show,
                  with: { params: params } do |result|
      return render json: {
        data: result[:model]
      }, status: :ok
    end

    render_operation_error(result, default_status: :not_found)
  end

  # POST /users
  def create
    result = run User::Operation::Create,
                  with: { user_params: user_params } do |result|
      return render json: {
        data: result[:model].as_json(
          only: [
            :id, :email, :role_id, :created_at, :updated_at
          ]
        )
      }, status: :created
    end

    render_operation_error(result)
  end

  # PATCH /users/:id
  def update
    result = run User::Operation::Update,
                  with: {
                    params: params,
                    user_params: user_params
                  } do |result|
      return render json: {
        data: result[:model].as_json(
          only: [
            :id, :email, :name, :address, :contact,
            :role_id, :created_at, :updated_at
          ]
        )
      }, status: :ok
    end

    render_operation_error(result, default_status: :unprocessable_entity)
  end

  # DELETE /users/:id
  def destroy
    result = run User::Operation::Destroy,
                  with: { params: params } do |_result|
      return head :no_content
    end

    render_operation_error(result, default_status: :not_found)
  end

  private

  def user_params
    params.expect(
      user: [
        :email, :password, :password_confirmation,
        :role_id, :name, :address, :contact
      ]
    )
  end
end
