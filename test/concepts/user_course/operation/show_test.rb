require "test_helper"

class UserCourseShowTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test "returns the saved lesson and page position" do
    assignment, lessons = build_assignment
    progress = assignment.user_lesson_progresses.create!(
      lesson: lessons.last,
      status: "in_progress",
      metadata: {
        "pages" => {},
        "current_position" => true,
        "current_page_position" => 2
      }
    )

    result = UserCourse::Operation::Show.call(
      params: ActionController::Parameters.new(id: assignment.id),
      current_user: assignment.user
    )

    assert result.success?
    assert_equal(
      {
        lesson_id: lessons.last.id,
        lesson_position: 2,
        page_id: lessons.last.lesson_pages.order(:position).second.id,
        page_number: 2,
        page_position: 2
      },
      result[:response_data][:resume_position]
    )
    assert_equal assignment.id, progress.user_course_id
  end

  test "defaults a learner without saved progress to the first page" do
    assignment, lessons = build_assignment

    result = UserCourse::Operation::Show.call(
      params: ActionController::Parameters.new(id: assignment.id),
      current_user: assignment.user
    )

    assert result.success?
    assert_equal lessons.first.id, result[:response_data][:resume_position][:lesson_id]
    assert_equal lessons.first.lesson_pages.order(:position).first.id,
                 result[:response_data][:resume_position][:page_id]
    assert_equal 1, result[:response_data][:resume_position][:page_number]
  end

  test "saving a new position clears the previous active lesson" do
    assignment, lessons = build_assignment
    previous_progress = assignment.user_lesson_progresses.create!(
      lesson: lessons.first,
      status: "in_progress",
      metadata: { "current_position" => true, "current_page_position" => 1 }
    )
    navigator = LessonProgressTracking::Operation::NavigatePage.allocate

    navigator.save_resume_position(assignment, lessons.last, 2)

    assert_not previous_progress.reload.metadata.key?("current_position")
    current_progress = assignment.user_lesson_progresses.find_by!(lesson: lessons.last)
    assert_equal true, current_progress.metadata["current_position"]
    assert_equal 2, current_progress.metadata["current_page_position"]
  end

  private

  def build_assignment
    admin_role = Role.create!(name: "admin")
    learner_role = Role.create!(name: "learner")
    admin = build_user("admin", admin_role)
    learner = build_user("learner", learner_role)
    category = Category.create!(category_name: "Resume test")
    course = Course.create!(category: category, title: "Resume course", status: "published")
    lessons = 2.times.map do |index|
      lesson = course.lessons.create!(title: "Lesson #{index + 1}", position: index + 1)
      2.times do |page_index|
        lesson.lesson_pages.create!(title: "Page #{page_index + 1}", position: page_index + 1)
      end
      lesson
    end
    assignment = UserCourse.create!(
      user: learner,
      course: course,
      assigned_by: admin,
      status: "assigned",
      total_lessons: lessons.size
    )

    [assignment, lessons]
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
