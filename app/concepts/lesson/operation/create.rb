module Lesson::Operation
  class Create < ApplicationOperation
    step :authorize_create
    step Model(Lesson, :new)
    step :build_lesson

    fail :handle_failure
    step :set_response

    def authorize_create(ctx, **)
      authorize_record(ctx, Lesson, :create?)
    end

    def build_lesson(ctx, params:, **)
      lesson_params = params.expect(
        lesson: [:course_id, :title, :content_type, :position,
          { lesson_pages_attributes: [[:id, :title, :topic, :content, :position, :_destroy, { metadata: {} }]] }]
      )
      ctx[:model].assign_attributes(lesson_params)

      if ctx[:model].save
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def set_response(ctx, **)
      ctx[:response_data] = { data: ctx[:model] }
      ctx[:status] = :created
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: ctx[:errors]&.join(", ") || "Lesson creation failed",
        status: :unprocessable_entity
      }
    end
  end
end
