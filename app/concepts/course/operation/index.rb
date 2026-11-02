
module Course::Operation
  class Index < Trailblazer::Operation
    step :fetch_courses
    fail :handle_failure

    def fetch_courses(ctx, **)
      ctx[:models] = Course.all.to_a
      true

    rescue StandardError => e
      Rails.logger.error("Course Index Error: #{e.full_message}")
      false
    end

    def handle_failure(ctx, **)
      ctx[:error] = "Unable to fetch courses"
    end
  end
end
