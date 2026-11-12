# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  private

  # Sign in response
  def respond_with(resource, _opts = {})
      render json: {
        message: "Signed in successfully.",
        data: {
          id: resource.id,
          email: resource.email,
          role: resource.role.name
        }
      }, status: :ok
  end

  # Sign out response
  def respond_to_on_destroy(non_navigational_status: :no_content)
    if request.headers["Authorization"].present?
      render json: { message: "Signed out successfully." }, status: :ok
    else
      render json: { message: "Couldn't find an active session." }, status: :unauthorized
    end
  end
end
