
class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :update, :destroy ]

  # GET /users
  def index
    users = User.all # asks Active Record to retrieve all users. users stores the result.
    # render json: sends the result as JSON.
    render json: users.as_json( # selects which fields to return in the API response.
      only: [ :id, :email, :role_id, :created_at, :updated_at ]
    ), status: :ok
  end

  # GET /users/:id
  def show
    render json: @user.as_json(
      only: [ :id, :email, :role_id, :created_at, :updated_at ]
    ), status: :ok
  end

  # POST /users
  def create
    user = User.new(user_params)
    # runs model validations and attempts to save the record to the database.
    if user.save
      render json: user.as_json(
        only: [ :id, :email, :role_id, :created_at, :updated_at ]
      ), status: :created
    else
      render json: { errors: user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # PATCH /users/:id
  def update
    if @user.update(user_params)
      render json: @user.as_json(
        only: [ :id, :email, :role_id, :created_at, :updated_at ]
      ), status: :ok
    else
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    @user.destroy!
    head :no_content # returns HTTP 204, meaning the operation succeeded and there is no response body.
  end

  private

  # Find the user before show, update, or destroy.
  def set_user
    @user = User.find(params[:id])
  end

  # Allow only approved attributes. Strong Parameters
  def user_params
    params.expect(
      user: [ :email, :password, :password_confirmation, :role_id ]
    )
  end
end
