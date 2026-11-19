require "test_helper"

class UserLessonProgressTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test "metadata must be an object" do
    progress = UserLessonProgress.new(
      status: "not_started",
      metadata: ["video"]
    )

    assert_not progress.valid?
    assert_includes progress.errors[:metadata], "must be an object"
  end

  test "metadata accepts independent content progress" do
    progress = UserLessonProgress.new(
      status: "in_progress",
      metadata: {
        "video" => { "watched_seconds" => 30 },
        "documentation" => { "completed" => true }
      }
    )

    progress.valid?

    assert_empty progress.errors[:metadata]
  end

  test "current page position must identify a page in the lesson" do
    progress = UserLessonProgress.new(
      metadata: {
        "current_position" => true,
        "current_page_position" => 2
      }
    )

    assert_not progress.valid?
    assert_includes progress.errors[:metadata],
                    "current page position must identify a page in the lesson"
  end
end
