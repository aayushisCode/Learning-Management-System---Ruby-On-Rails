class ApplicationController < ActionController::API
  private

  def render_operation_error(result, default_status: :unprocessable_entity)
    error = result[:error]

    render json: {
      error: error.is_a?(Hash) ? error[:msg] : error,
      errors: result[:errors]
    }.compact,
    status: (error.is_a?(Hash) && error[:code]) || default_status
  end
end
