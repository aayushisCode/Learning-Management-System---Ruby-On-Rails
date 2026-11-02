module Lesson::Operation
  class Index < Trailblazer::Operation
    step :fetch_lessons
    fail :handle_failure

    def fetch_lessons(ctx, **)
      ctx[:models] = Lesson.all.to_a
      # .to_a executes the query and loads the records immediately,
      # so database errors can be caught by the rescue block.
      true
    end

    def handle_failure(ctx, **)
      ctx[:error] = "Unable to fetch lessons"
    end
  end
end
