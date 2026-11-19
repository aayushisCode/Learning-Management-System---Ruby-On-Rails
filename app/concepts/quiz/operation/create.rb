
module Quiz::Operation
  class Create < ApplicationOperation
    step :authorize_create
    step Model(Quiz, :new)
    step :build_quiz
    step :save_quiz

    fail :handle_failure
    step :set_response

    def authorize_create(ctx, **)
      authorize_record(ctx, Quiz, :create?)
    end

    def build_quiz(ctx, params:, **)
      quiz_params = params.require(:quiz).permit(
        :course_id, :lesson_id, :title, :description, :quiz_type, :pass_marks
      )
      quiz_params[:course_id] ||= params[:course_id] if params[:course_id].present?
      ctx[:model].assign_attributes(
        permitted_attributes(quiz_params)
      )

      true
    end

    def save_quiz(ctx, **)
      unless ctx[:model].save
        ctx[:errors] = ctx[:model].errors.full_messages
        return false
      end

      true
    end

    def set_response(ctx, **)
      ctx[:response_data] = { data: ctx[:model] }
      ctx[:status] = :created
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: ctx[:errors]&.join(", ") || "Unable to create quiz",
        status: :unprocessable_entity
      }
    end

    private

    def permitted_attributes(quiz_params)
      quiz_params.to_h.symbolize_keys.slice(
        :course_id,
        :lesson_id,
        :title,
        :description,
        :quiz_type,
        :pass_marks
      )
    end
  end
end
