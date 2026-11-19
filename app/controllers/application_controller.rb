class ApplicationController < ActionController::API
  include Pundit::Authorization

  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError,
              with: :user_not_authorized

  private

  # trailblazer-rails supplies params by default; current_user is the only
  # request dependency it does not expose to operations.
  def _run_options(context)
    context.merge(current_user: current_user)
  end

  # Handles Pundit authorization failures
  def user_not_authorized
    render json: {
      msg: "You are not authorized to perform this action."
    }, status: :forbidden
  end

  # Render the response data produced by a successful Trailblazer operation.
  def render_operation_response(result)
    render json: result[:response_data] || { data: result[:model] },
           status: result[:status] || :ok
  end

  # def render_operation_error(result, default_status: :unprocessable_entity)
  #   error = result[:error] || {}
  #   response = result[:response_data]
  #   message = error[:msg] || response&.dig(:msg) || "Request failed"
  #   status = error[:status] || result[:status] || default_status

  #   render json: { error: message }, status: status
  # end
  def render_operation_error(result, default_status: :unprocessable_entity)
    error = result[:error] || {}
    response = result[:response_data]

    message = error[:msg] || response&.dig(:msg) || "Request failed"
    status = error[:status] || result[:status] || default_status

    render json: { msg: message }, status: status
  end
end
