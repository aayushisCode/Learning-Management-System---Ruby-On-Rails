
module User::Operation
  class Update < ApplicationOperation
    step :find_user
    step :update_user
    fail :handle_failure
    step :set_response

    def find_user(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, User).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :update?)
      true
    end

    def set_response(ctx, **)
      ctx[:response_data] = {
        data: ctx[:model].as_json(only: [:id, :email, :name, :address, :contact, :role_id, :created_at, :updated_at])
      }
      ctx[:status] = :ok
    end

    def update_user(ctx, params:, **)
      attributes = params.require(:user).permit(
        :email, :password, :password_confirmation, :role_id,
        :name, :address, :contact
      )
      unless ctx[:model].update(attributes)
        ctx[:errors] = ctx[:model].errors.full_messages
        return false
      end

      true
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= if ctx[:model].nil?
        {
          msg: "User not found",
          status: :not_found
        }
      else
        {
          msg: "User update failed",
          status: :unprocessable_entity
        }
      end
    end
  end
end
