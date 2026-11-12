module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    private

    def require_admin!
      return if current_user&.admin?

      render json: {
        error: "Access denied",
        status: :forbidden
      }, status: :forbidden
    end
  end
end
