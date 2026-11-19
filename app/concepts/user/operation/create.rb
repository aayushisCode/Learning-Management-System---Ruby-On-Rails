
module User::Operation
  class Create < ApplicationOperation
    step :authorize_create
    step Model(User, :new)
    step :create_user
    fail :handle_failure
    step :set_response

    def authorize_create(ctx, **)
      authorize_record(ctx, User, :create?)
    end

    def set_response(ctx, **)
      ctx[:response_data] = { data: ctx[:model].as_json(only: [:id, :email, :role_id, :created_at, :updated_at]) }
      ctx[:status] = :created
    end

    def create_user(ctx, params:, **)
      attributes = params.require(:user).permit(
        :email, :password, :password_confirmation, :role_id,
        :name, :address, :contact
      )
      ctx[:model].assign_attributes(attributes)

      if ctx[:model].save
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "User creation failed",
        status: :unprocessable_entity
      }
    end
  end
end
