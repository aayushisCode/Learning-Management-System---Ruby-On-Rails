
module Lesson::Operation
  class Update < ApplicationOperation
    step :find_lesson
    step :update_lesson
    fail :handle_failure
    step :set_response

    def find_lesson(ctx, params:, **)
      ctx[:model] = policy_scope_for(ctx, Lesson).find_by(id: params[:id])
      return false unless ctx[:model]
      authorize_record(ctx, ctx[:model], :update?)
      true
    end

    def update_lesson(ctx, params:, **)
      lesson_params = params.expect(
        lesson: [:course_id, :title, :content_type, :position,
          { lesson_pages_attributes: [[:id, :title, :topic, :content, :position, :_destroy, { metadata: {} }]] }]
      )
      if ctx[:model].update(lesson_params)
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def set_response(ctx, **)
      ctx[:response_data] = {
        data: ctx[:model].as_json(
          only: [:id, :course_id, :title, :content_type, :position, :created_at, :updated_at],
          include: { lesson_pages: { only: [:id, :lesson_id, :title, :topic, :content, :metadata, :position] } }
        )
      }
      ctx[:status] = :ok
    end

    def handle_failure(ctx, **)
      ctx[:error] = if ctx[:model].nil?
        {
          msg: "Lesson not found",
          status: :not_found
        }
      else
        {
          msg: "Lesson update failed",
          status: :unprocessable_entity
        }
      end
    end
  end
end
