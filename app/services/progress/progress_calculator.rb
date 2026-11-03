module Learning
  class ProgressCalculator
    def initialize(lesson_progress)
      @lesson_progress = lesson_progress
    end

    def calculate
      return 0 if @lesson_progress.total_pages.zero?

      (
        @lesson_progress.completed_pages.to_f /
        @lesson_progress.total_pages * 100
      ).round(2)
    end

    def update
      percentage = calculate

      @lesson_progress.update!(
        progress_percentage: percentage,
        status: determine_status
      )

      percentage
    end

    private

    def determine_status
      return "not_started" if @lesson_progress.completed_pages.zero?

      "in_progress"
    end
  end
end
