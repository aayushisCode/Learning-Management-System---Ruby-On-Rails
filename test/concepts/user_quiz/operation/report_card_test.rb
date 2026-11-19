require "test_helper"

class UserQuizReportCardTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test "denies access when the assignment belongs to another learner" do
    data = build_report_card_data
    other_learner = build_user("other-learner", Role.find_by!(name: "learner"))

    result = call_report_card(
      data[:user_course].id,
      data[:quiz].id,
      current_user: other_learner
    )

    assert result.failure?
    assert_equal :not_found, result[:error][:status]
  end

  test "returns not found for a missing assignment or a quiz from another course" do
    data = build_report_card_data
    other_course = Course.create!(
      category: data[:category],
      title: "Other course",
      status: "published"
    )
    other_quiz = other_course.quizzes.create!(
      title: "Other quiz",
      quiz_type: "final",
      pass_marks: 50
    )

    missing_assignment = call_report_card(
      SecureRandom.uuid,
      data[:quiz].id,
      current_user: data[:learner]
    )
    unrelated_quiz = call_report_card(
      data[:user_course].id,
      other_quiz.id,
      current_user: data[:learner]
    )

    assert missing_assignment.failure?
    assert_equal :not_found, missing_assignment[:error][:status]
    assert unrelated_quiz.failure?
    assert_equal :not_found, unrelated_quiz[:error][:status]
  end

  test "does not return an in-progress attempt when there is no submission" do
    data = build_report_card_data
    data[:user_course].user_quizzes.create!(
      quiz: data[:quiz],
      attempt_number: 1,
      status: "in_progress"
    )

    result = call_report_card(data[:user_course].id, data[:quiz].id, current_user: data[:learner])

    assert result.failure?
    assert_equal :not_found, result[:error][:status]
  end

  test "returns the latest submitted attempt with correct and incorrect answers" do
    data = build_report_card_data
    create_attempt(data, attempt_number: 1, score: 0, result: "fail")
    latest = create_attempt(data, attempt_number: 2, score: 1, result: "fail")
    data[:user_course].user_quizzes.create!(
      quiz: data[:quiz],
      attempt_number: 3,
      status: "in_progress"
    )
    UserOption.create!(
      user_quiz: latest,
      question: data[:questions][0],
      option: data[:questions][0].correct_option
    )
    UserOption.create!(
      user_quiz: latest,
      question: data[:questions][1],
      option: data[:questions][1].options.find { |option| option.id != data[:questions][1].correct_option_id }
    )

    result = call_report_card(data[:user_course].id, data[:quiz].id, current_user: data[:learner])

    assert result.success?
    card = result[:response_data]
    assert_equal data[:quiz].id, card[:quiz_id]
    assert_equal data[:quiz].title, card[:quiz_title]
    assert_equal 2, card[:attempt_number]
    assert_equal 2, card[:questions].size

    correct_answer, incorrect_answer = card[:questions]
    assert_equal true, correct_answer[:is_correct]
    assert_equal data[:questions][0].correct_option_id, correct_answer[:selected_option_id]
    assert_equal data[:questions][0].correct_option.option_text, correct_answer[:correct_option_text]
    assert_equal false, incorrect_answer[:is_correct]
    assert_equal data[:questions][1].correct_option_id, incorrect_answer[:correct_option_id]
    assert_equal data[:questions][1].correct_option.option_text, incorrect_answer[:correct_option_text]
  end

  private

  def call_report_card(user_course_id, quiz_id, current_user:)
    UserQuiz::Operation::ReportCard.call(
      params: ActionController::Parameters.new(
        user_course_id: user_course_id,
        quiz_id: quiz_id
      ),
      current_user: current_user
    )
  end

  def build_report_card_data
    admin_role = Role.create!(name: "admin")
    learner_role = Role.create!(name: "learner")
    admin = build_user("admin", admin_role)
    learner = build_user("learner", learner_role)
    category = Category.create!(category_name: "Report card")
    course = Course.create!(category: category, title: "Report card course", status: "published")
    quiz = course.quizzes.create!(title: "Final quiz", quiz_type: "final", pass_marks: 50)
    questions = 2.times.map do |index|
      question = Question.create!(
        category: category,
        course: course,
        quiz: quiz,
        question_text: "Question #{index + 1}",
        question_type: "mcq",
        marks: 1,
        position: index + 1
      )
      correct_option = question.options.create!(option_text: "Correct #{index + 1}", position: 1)
      question.options.create!(option_text: "Incorrect #{index + 1}", position: 2)
      question.update!(correct_option: correct_option)
      question
    end
    user_course = UserCourse.create!(
      user: learner,
      course: course,
      assigned_by: admin,
      status: "assigned",
      total_lessons: 0
    )

    {
      admin: admin,
      learner: learner,
      category: category,
      course: course,
      quiz: quiz,
      questions: questions,
      user_course: user_course
    }
  end

  def create_attempt(data, attempt_number:, score:, result:)
    data[:user_course].user_quizzes.create!(
      quiz: data[:quiz],
      attempt_number: attempt_number,
      status: "submitted",
      score: score,
      total_marks: 2,
      pass_marks: data[:quiz].pass_marks,
      percentage: score * 50,
      result: result,
      started_at: 10.minutes.ago,
      submitted_at: attempt_number.minutes.ago
    )
  end

  def build_user(prefix, role)
    User.create!(
      name: prefix.tr("-", " ").capitalize,
      email: "#{prefix}-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      address: "Test address",
      contact: "+12345678901",
      role: role
    )
  end
end
