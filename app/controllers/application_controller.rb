class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authorize_roles!(*roles)
    current_role = current_user&.role&.name.to_s.downcase
    allowed_roles = roles.map { |role| role.to_s.downcase }

    return true if allowed_roles.include?(current_role)

    render json: {
      error: "You are not authorized",
      status: :forbidden
    }, status: :forbidden
  end

  def render_operation_error(result, default_status: :unprocessable_entity)
    error = result[:error] || {}

    render json: {
      error: error[:msg] || "Something went wrong"
    }, status: error[:status] || default_status
  end
end
