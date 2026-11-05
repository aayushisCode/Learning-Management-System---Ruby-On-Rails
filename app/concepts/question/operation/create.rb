module Question::Operation
  class Create < Trailblazer::Operation
    step :build_question
    step :validate_question_relationships
    step :validate_options
    step :save_question_and_options
    fail :handle_failure

    def build_question(ctx, params:, **)
      attributes = permitted_attributes(params, :question)

      ctx[:options_attributes] = attributes.delete(:options)
      ctx[:correct_option_position] = attributes.delete(:correct_option_position)

      ctx[:model] = Question.new(attributes)
      true
    end

    def validate_question_relationships(ctx, **)
      question = ctx[:model]

      quiz = Quiz.find_by(id: question.quiz_id)
      course = Course.find_by(id: question.course_id)
      category = Category.find_by(id: question.category_id)

      unless quiz && course && category
        ctx[:error] = "Quiz, course or category not found"
        return false
      end

      unless quiz.course_id == question.course_id
        ctx[:error] = "Question course must match quiz course"
        return false
      end

      unless course.category_id == question.category_id
        ctx[:error] = "Question category must match course category"
        return false
      end

      true
    end

    def validate_options(ctx, **)
      question = ctx[:model]
      options = ctx[:options_attributes]

      unless options.is_a?(Array)
        ctx[:error] = "Options must be an array"
        return false
      end

      expected_count = case question.question_type
      when "mcq" then 4
      when "boolean" then 2
      else
                         ctx[:error] = "Question type must be mcq or boolean"
                         return false
      end

      unless options.size == expected_count
        ctx[:error] = "#{question.question_type} must have exactly #{expected_count} options"
        return false
      end

      positions = options.map { |option| option[:position].to_i }

      unless positions.sort == (1..expected_count).to_a
        ctx[:error] = "Option positions must be consecutive and start from 1"
        return false
      end

      if question.question_type == "boolean"
        option_texts = options.map do |option|
          option[:option_text].to_s.strip.downcase
        end

        unless option_texts.sort == %w[false true]
          ctx[:error] = "Boolean options must be True and False"
          return false
        end
      end

      correct_position = Integer(ctx[:correct_option_position], exception: false)

      unless correct_position && (1..expected_count).cover?(correct_position)
        ctx[:error] = "Select a valid correct_option_position"
        return false
      end

      ctx[:correct_option_position] = correct_position
      true
    end

    def save_question_and_options(ctx, **)
      question = ctx[:model]
      options = ctx[:options_attributes]

      saved = false

      ActiveRecord::Base.transaction do
        question.save!

        created_options = options.map do |attributes|
          question.options.create!(
            option_text: attributes[:option_text],
            position: attributes[:position]
          )
        end

        correct_option = created_options.find do |option|
          option.position == ctx[:correct_option_position]
        end

        question.update!(correct_option: correct_option)

        saved = true
      end

      unless saved
        ctx[:error] ||= "Unable to create question"
        return false
      end

      ctx[:model] = question
      true

    rescue ActiveRecord::RecordInvalid => e
      ctx[:error] = e.record.errors.full_messages
      false
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= ctx[:model]&.errors&.full_messages ||
                      "Unable to create question"
      true
    end

    private

    def permitted_attributes(params, key)
      attributes = params[key] || {}
      attributes = attributes.to_unsafe_h if attributes.respond_to?(:to_unsafe_h)
      attributes = attributes.with_indifferent_access

      attributes.slice(
        :category_id,
        :course_id,
        :quiz_id,
        :question_text,
        :question_type,
        :marks,
        :position,
        :status,
        :options,
        :correct_option_position
      )
    end
  end
end
