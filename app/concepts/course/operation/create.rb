
module Course::Operation
  class Create < ApplicationOperation
    step :authorize_create
    step Model(Course, :new)
    step :build_course
    fail :handle_failure

    step :success_response


    def build_course(ctx, **)
      attributes = ctx[:params].require(:course).permit(:category_id, :title, :description, :status)
      ctx[:model].assign_attributes(attributes)
      ctx[:model].save
    end

    def authorize_create(ctx, **)
      authorize_record(ctx, Course, :create?)
    end

    def handle_failure(ctx, **)
      ctx[:response_data] = {
        msg: "Course creation failed",
        errors: ctx[:model].errors.full_messages
      }
      ctx[:status] = :unprocessable_entity
    end

    def success_response(ctx, **)
      ctx[:response_data] = {
        msg: "Course Created Successfully",
        data: ctx[:model].as_json(
          only: %i[id category_id title description status]
        )
      }
      ctx[:status] = :created
    end
  end
end
