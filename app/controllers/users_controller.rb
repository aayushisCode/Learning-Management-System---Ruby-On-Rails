
class UsersController < ApplicationController
  # GET /users
  def index
    result = User::Operation::Index.call

    if result.success?
      render json: result[:models].as_json(
      only: [ :id, :email, :role_id, :created_at, :updated_at ]
    ), status: :ok
    else
      render json: { error: result[:error] },
      status: :internal_server_error
    end
  end

  # GET /users/:id
  def show
    result = User::Operation::Show.call(params: params)
    if result.success?
      render json: result[:model], status: :ok
    else
      render json: { error: result[:error] }, status: :not_found
    end
  end

  # POST /users
  def create
    result = User::Operation::Create.call(user_params: user_params)
    if result.success?
      render json: result[:model].as_json(
        only: [ :id, :email, :role_id, :created_at, :updated_at ]
      ), status: :created
    else
      render json: { errors: result[:errors] },
             status: :unprocessable_entity
    end
  end

  # PATCH /users/:id
  def update
   result = User::Operation::Update.call(params: params, user_params: user_params)
   if result.success?
     render json: result[:model].as_json(
      only: [ :id, :email, :name, :address, :contact, :role_id, :created_at, :updated_at ]
     ), status: :ok
   else
    if result[:error]
      render json: { error: result[:error] }, status: :not_found
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
   end
  end

  # DELETE /users/:id
  def destroy
    result = User::Operation::Destroy.call(params: params)
    if result.success?
      head :no_content # returns HTTP 204, meaning the operation succeeded and there is no response body.
    else
      render json: { error: result[:error] }, status: :not_found
    end
  end

  private
  # internal helper methods.
  # Find the user before destroy.
  # def set_user
  #   @user = User.find(params[:id])
  # end

  # Allow only approved attributes. Strong Parameters
  def user_params
    params.expect(
      user: [ :email, :password, :password_confirmation, :role_id, :name, :address, :contact ]
    )
  end
end
