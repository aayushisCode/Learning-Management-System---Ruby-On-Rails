class CategoriesController < ApplicationController
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
end
