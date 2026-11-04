class CategoriesController < ApplicationController
  # GET /categories
  def index
    result = Category::Operation::Index.call

    if result.success?
      render json: result[:models].as_json(
        only: [ :id, :category_name, :description, :created_at, :updated_at ]
      ), status: :ok
    else
      render json: { error: result[:error] },
             status: :internal_server_error
    end
  end

  # GET /categories/:id
  def show
    result = Category::Operation::Show.call(params: params)

    if result.success?
      render json: result[:model], status: :ok
    else
      render json: { error: result[:error] }, status: :not_found
    end
  end

  # POST /categories
  def create
    result = Category::Operation::Create.call(
      category_params: category_params
    )

    if result.success?
      render json: result[:model], status: :created
    else
      render json: {
        error: result[:error],
        errors: result[:errors]
      }, status: :unprocessable_entity
    end
  end

  # PATCH /categories/:id
  def update
    result = Category::Operation::Update.call(
      params: params,
      category_params: category_params
    )

    if result.success?
      render json: result[:model], status: :ok
    else
      render json: {
        error: result[:error],
        errors: result[:errors]
      }, status: :unprocessable_entity
    end
  end

  # DELETE /categories/:id
  def destroy
    result = Category::Operation::Destroy.call(params: params)

    if result.success?
      render json: { message: "Category deleted successfully" },
             status: :ok
    else
      render json: {
        error: result[:error],
        errors: result[:errors]
      }, status: :unprocessable_entity
    end
  end

  private

  def category_params
    params.require(:category).permit(:category_name, :description)
  end
end
