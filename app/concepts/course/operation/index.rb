
module Course::Operation
  class Index < Trailblazer::Operation
    step :fetch_courses
    fail :handle_failure

    def fetch_courses(ctx, **)
      ctx[:models] = Course.all.to_a
    rescue StandardError => e
      Rails.logger.error("Course Index Error: #{e.full_message}")
      false
    end

    def handle_failure(ctx, **)
      ctx[:error] = {
        msg: "Unable to fetch courses",
        status: :internal_server_error
      }
    end
  end
end
