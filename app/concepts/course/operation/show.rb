module Course::Operation
  class Show < Trailblazer::Operation
    step :find_course
    fail :course_not_found

    def find_course(ctx, params:, **)
      ctx[:model] = Course.find_by(id: params[:id])

      return false unless ctx[:model]

      true
    end

    def course_not_found(ctx, **)
      ctx[:error] = "Course not found"
    end
  end
end
