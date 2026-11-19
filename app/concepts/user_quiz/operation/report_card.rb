module UserQuiz::Operation
  class ReportCard < ApplicationOperation
    step :find_user_course
    step :find_quiz
    step :find_latest_submitted_attempt
    step :build_response

    def find_user_course(ctx, params:, **)
      user_course = policy_scope_for(ctx, UserCourse).find_by(
        id: params[:user_course_id]
      )

      unless user_course
        ctx[:error] = {
          msg: "Course assignment not found",
          status: :not_found
        }
        return false
      end

      authorize_record(ctx, user_course, :start_quiz?)
      ctx[:user_course] = user_course
    end

    def find_quiz(ctx, params:, user_course:, **)
      quiz = user_course.course.quizzes.find_by(id: params[:quiz_id])

      unless quiz
        ctx[:error] = {
          msg: "Quiz not found for this course",
          status: :not_found
        }
        return false
      end

      ctx[:quiz] = quiz
    end

    def find_latest_submitted_attempt(ctx, user_course:, quiz:, **)
      attempt = user_course.user_quizzes
                          .where(quiz_id: quiz.id, status: "submitted")
                          .order(attempt_number: :desc)
                          .includes(
                            user_options: [:option, :question],
                            quiz: { questions: :correct_option }
                          )
                          .first

      unless attempt
        ctx[:error] = {
          msg: "No submitted attempt found for this quiz",
          status: :not_found
        }
        return false
      end

      ctx[:attempt] = attempt
    end

    def build_response(ctx, attempt:, **)
      quiz = attempt.quiz
      selected_options = attempt.user_options.index_by(&:question_id)

      ctx[:response_data] = {
        quiz_id: quiz.id,
        quiz_title: quiz.title,
        attempt_number: attempt.attempt_number,
        score: attempt.score,
        total_marks: attempt.total_marks,
        percentage: attempt.percentage,
        result: attempt.result,
        questions: quiz.questions.sort_by(&:position).map do |question|
          answer = selected_options[question.id]
          selected_option = answer&.option
          correct_option = question.correct_option

          {
            question_id: question.id,
            question_text: question.question_text,
            selected_option_id: selected_option&.id,
            selected_option_text: selected_option&.option_text,
            correct_option_id: question.correct_option_id,
            correct_option_text: correct_option&.option_text,
            is_correct: selected_option.present? &&
                        selected_option.id == question.correct_option_id
          }
        end
      }
      ctx[:status] = :ok
    end
  end
end
