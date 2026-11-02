module Course::Operation
  class Destroy < Trailblazer::Operation
    step :find_course
    step :delete_course
    fail :handle_failure

    def find_course(ctx, params:, **)
      ctx[:model] = Course.find_by(id: params[:id])

      return false unless ctx[:model]

      true
    end

    def delete_course(ctx, **)
      if ctx[:model].destroy
        true
      else
        false unless ctx[:model].destroy
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "Course deletion failed"
    end
  end
end
