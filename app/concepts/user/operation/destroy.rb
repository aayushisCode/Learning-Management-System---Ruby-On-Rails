module User::Operation
  class Destroy < Trailblazer::Operation
    # destroy runs ActiveRecord callbacks(before_destroy or after_destroy.), whereas delete skips them.
    step :find_user
    fail :user_not_found, fail_fast: true

    step :destroy_user
    fail :destroy_failed, fail_fast: true # stop the activity immediately after this failure

    def find_user(ctx, params:, **)
      ctx[:model] = User.find_by(id: params[:id])
      return false unless ctx[:model] # if the user is not found, return false to trigger the failure step
      true
    end

    def user_not_found(ctx, **)
      ctx[:error] ||= "User not found"
    end

    def destroy_user(ctx, **)
      if ctx[:model].destroy
        true
      else
        false
      end
    end

    def destroy_failed(ctx, **)
      ctx[:error] ||= "Failed to delete user"
    end
  end
end
