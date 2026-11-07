class CategoriesController < ApplicationController
  # GET /categories
  def index
    result = run Category::Operation::Index.call(params: params) do |result|
      return render json: { data: result[:response_data] }, status: :ok
    end
    render json: { error: result[:error][:msg] }, status: result[:error][:status]
  end

  # GET /categories/:id
  def show
    result = run Category::Operation::Show, with: { params: params } do |result|
      return render json: { data: result[:response_data] }, status: :ok
    end
    render json: { error: result[:error][:msg] }, status: result[:error][:status]
  end

  # POST /categories
  def create
    result = run Category::Operation::Create,
    with: { category_params: category_params } do |result|
      return render json: { data: result[:response_data] }, status: :created
    end
    render json: { error: result[:error][:msg] }, status: result[:error][:status]
  end

  # PATCH /categories/:id
  def update
    result = run Category::Operation::Update,
    with: { params: params, category_params: category_params } do |result|
      return render json: { data: result[:response_data] }, status: :ok
    end
    render json: { error: result[:error][:msg] }, status: result[:error][:status]
  end

  # DELETE /categories/:id
  def destroy
    result = run Category::Operation::Destroy, with: { params: params } do |result|
      return render json: { data: result[:response_data] }, status: :ok
    end
    render json: { error: result[:error][:msg] }, status: result[:error][:status]
  end

  private

  def category_params
    params.require(:category).permit(:category_name, :description)
  end
end
