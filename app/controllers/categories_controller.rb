class CategoriesController < ApplicationController
  # GET /categories
  def index
    result = run Category::Operation::Index,
                with: { params: params } do |result|
      return render json: {
        data: result[:models]
      }, status: :ok
    end

    render json: {
      error: result[:error][:msg]
    }, status: result[:error][:status]
  end

  # GET /categories/:id
  def show
  
    result = run Category::Operation::Show,  model_params: {id: params[:id] }  do |result|
      return render json: { data: result[:model] }, status: :ok
    end

    render json: { error: result[:error][:msg] }, status: result[:error][:status]
  end

  # POST /categories
  # def create
  #   result = run Category::Operation::Create,
  #               with: {
  #                 category_params: category_params,
  #                 current_user: current_user
  #               } do |result|
  #     return render json: {
  #       data: result[:model]
  #     }, status: :created
  #   end

  #   render json: {
  #     error: result[:error][:msg]
  #   }, status: result[:error][:status]
  # end
  def create
    result = run Category::Operation::Create,
      category_params: category_params,
      current_user: current_user do |result|
      return render json: { data: result[:model] }, status: :created
    end
    render json: { error: result[:error][:msg] }, status: result[:error][:status]
  end


  # PATCH /categories/:id
  def update
    # binding.pry
    result = run Category::Operation::Update, params: params, category_params: category_params do |result|
      return render json: { data: result[:model] }, status: :ok
    end
    render json: { error: result[:error][:msg] }, status: result[:error][:status]
  end

  # if result.success?
  #   render json: {
  #     data: result[:model]
  #   }, status: :ok
  # else
  #   render json: {
  #     error: result[:error][:msg]
  #   }, status: result[:error][:status]
  # end
  # end

  # DELETE /categories/:id
  def destroy
    result = run Category::Operation::Destroy, params: params, current_user: current_user  do |result|
      return render json: { data: result[:response_data] }, status: :ok
    end
    render json: { error: result[:error][:msg] }, status: result[:error][:status]
  end

  private

  def category_params
    params.require(:category).permit(:id, :category_name, :description)
  end
end
