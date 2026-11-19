require "test_helper"

class LearnerCourseApiTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test "course index includes ordered lessons, learner progress, quiz states, and resume position" do
    data = build_course_assignment
    data[:user_course].user_lesson_progresses.create!(
      lesson: data[:first_lesson],
      status: "in_progress",
      started_at: Time.current,
      metadata: { "pages" => { data[:first_page].id => { "completed" => true } } }
    )
    data[:user_course].save_resume_position(lesson: data[:first_lesson], page_number: 2)
    data[:user_course].user_quizzes.create!(
      quiz: data[:lesson_quiz],
      attempt_number: 1,
      status: "submitted",
      score: 1,
      total_marks: 1,
      pass_marks: data[:lesson_quiz].pass_marks,
      percentage: 100,
      result: "pass",
      submitted_at: Time.current
    )
    data[:user_course].user_quizzes.create!(
      quiz: data[:final_quiz],
      attempt_number: 1,
      status: "in_progress"
    )

    result = UserCourse::Operation::Index.call(
      params: ActionController::Parameters.new({}),
      current_user: data[:learner]
    )

    assert result.success?
    assignment = result[:response_data][:data].first
    lessons = assignment[:course][:lessons]
    assert_equal [1, 2], lessons.map { |lesson| lesson[:position] }
    assert_equal "submitted", lessons.first[:lesson_quiz][:status]
    assert_equal "pass", lessons.first[:lesson_quiz][:result]
    assert_equal "pending", assignment[:course][:final_quiz][:status]
    assert_equal "in_progress", assignment[:course][:final_quiz][:attempt_status]
    assert_equal data[:first_lesson].id, assignment[:resume_position][:lesson_id]
    assert_equal 2, assignment[:resume_position][:page_number]
  end

  test "nested lesson show returns ordered page content and learner-specific progress" do
    data = build_course_assignment
    data[:user_course].user_lesson_progresses.create!(
      lesson: data[:first_lesson],
      status: "in_progress",
      started_at: Time.current,
      metadata: { "pages" => { data[:first_page].id => { "completed" => true } } }
    )
    data[:user_course].save_resume_position(lesson: data[:first_lesson], page_number: 2)

    result = Lesson::Operation::Show.call(
      params: ActionController::Parameters.new(
        id: data[:first_lesson].id,
        user_course_id: data[:user_course].id
      ),
      current_user: data[:learner]
    )

    assert result.success?
    lesson = result[:response_data][:data]
    assert_equal [1, 2], lesson[:lesson_pages].map { |page| page[:position] }
    assert_equal "Page body 1", lesson[:lesson_pages].first[:content]
    assert_equal true, lesson[:lesson_pages].first.dig(:user_lesson_progress, :completed)
    assert_equal false, lesson[:lesson_pages].second.dig(:user_lesson_progress, :completed)
    assert_equal 2, lesson[:current_page][:page_number]
    assert_equal data[:lesson_quiz].id, lesson[:lesson_quiz][:id]
  end

  test "course index keeps quiz progress isolated to each learner assignment" do
    data = build_course_assignment
    other_learner = build_user("other-learner", Role.find_by!(name: "learner"))
    other_assignment = UserCourse.create!(
      user: other_learner,
      course: data[:course],
      assigned_by: data[:admin],
      status: "assigned",
      total_lessons: 2
    )
    other_assignment.user_quizzes.create!(
      quiz: data[:lesson_quiz],
      attempt_number: 1,
      status: "submitted",
      score: 0,
      total_marks: 1,
      pass_marks: data[:lesson_quiz].pass_marks,
      percentage: 0,
      result: "fail",
      submitted_at: Time.current
    )

    result = UserCourse::Operation::Index.call(
      params: ActionController::Parameters.new({}),
      current_user: data[:learner]
    )

    assert result.success?
    assignments = result[:response_data][:data]
    assert_equal [data[:user_course].id], assignments.map { |assignment| assignment[:id] }
    own_quiz = assignments.first[:course][:lessons].first[:lesson_quiz]
    assert_equal "pending", own_quiz[:status]
    assert_nil own_quiz[:result]

    other_assignment_lesson = Lesson::Operation::Show.call(
      params: ActionController::Parameters.new(
        id: data[:first_lesson].id,
        user_course_id: other_assignment.id
      ),
      current_user: data[:learner]
    )
    assert other_assignment_lesson.failure?
  end

  test "quiz submission response includes score, result, percentage, and submitted status" do
    data = build_course_assignment
    attempt = data[:user_course].user_quizzes.create!(
      quiz: data[:final_quiz],
      attempt_number: 1,
      status: "in_progress"
    )
    UserOption.create!(
      user_quiz: attempt,
      question: data[:final_question],
      option: data[:correct_option]
    )

    result = UserQuiz::Operation::Submit.call(
      params: ActionController::Parameters.new(id: attempt.id),
      current_user: data[:learner]
    )

    assert result.success?
    assert_equal "submitted", result[:response_data][:status]
    assert_equal 1, result[:response_data][:score]
    assert_equal 1, result[:response_data][:total_marks]
    assert_equal 100, result[:response_data][:percentage]
    assert_equal "pass", result[:response_data][:result]
  end

  private

  def build_course_assignment
    admin_role = Role.create!(name: "admin")
    learner_role = Role.create!(name: "learner")
    admin = build_user("admin", admin_role)
    learner = build_user("learner", learner_role)
    category = Category.create!(category_name: "Learner course API")
    course = Course.create!(category: category, title: "Course API course", status: "published")

    first_lesson = course.lessons.create!(title: "Lesson 1", position: 1)
    second_lesson = course.lessons.create!(title: "Lesson 2", position: 2)
    first_page = first_lesson.lesson_pages.create!(
      title: "Page 1", content: "Page body 1", position: 1
    )
    first_lesson.lesson_pages.create!(
      title: "Page 2", content: "Page body 2", position: 2
    )
    second_lesson.lesson_pages.create!(title: "Page 1", position: 1)

    lesson_quiz = course.quizzes.create!(
      lesson: first_lesson,
      title: "Lesson quiz",
      quiz_type: "lesson",
      pass_marks: 60
    )
    final_quiz = course.quizzes.create!(
      title: "Final quiz",
      quiz_type: "final",
      pass_marks: 60
    )
    final_question = Question.create!(
      category: category,
      course: course,
      quiz: final_quiz,
      question_text: "Final question",
      question_type: "mcq",
      marks: 1,
      position: 1
    )
    correct_option = final_question.options.create!(option_text: "Correct", position: 1)
    final_question.options.create!(option_text: "Incorrect", position: 2)
    final_question.update!(correct_option: correct_option)

    user_course = UserCourse.create!(
      user: learner,
      course: course,
      assigned_by: admin,
      status: "assigned",
      total_lessons: 2
    )

    {
      admin: admin,
      learner: learner,
      course: course,
      first_lesson: first_lesson,
      first_page: first_page,
      lesson_quiz: lesson_quiz,
      final_quiz: final_quiz,
      final_question: final_question,
      correct_option: correct_option,
      user_course: user_course
    }
  end

  def build_user(prefix, role)
    User.create!(
      name: prefix.capitalize,
      email: "#{prefix}-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      address: "Test address",
      contact: "+12345678901",
      role: role
    )
  end
end
