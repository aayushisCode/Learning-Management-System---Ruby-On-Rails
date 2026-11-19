module Course::Operation
  class Index < ApplicationOperation
    step :fetch_courses
    fail :handle_failure
    step :success_response

    def fetch_courses(ctx, **)
      pundit = Pundit::Context.new(user: ctx[:current_user])
      pundit.authorize(Course, query: :index?, policy_class: nil)
      ctx[:models] = pundit.policy_scope(Course).to_a
      true
    rescue StandardError => e
      Rails.logger.error("Course Index Error: #{e.full_message}")
      false
    end

    def handle_failure(ctx, **)
      ctx[:response_data] = {
        msg: "Unable to fetch courses"
      }
      ctx[:status] = :internal_server_error
    end

    def success_response(ctx, **)
      ctx[:response_data]= {
        data: ctx[:models].as_json(
          only: %i[id category_id title description status]
        )
      }
      ctx[:status] = :ok
    end
  end
end
