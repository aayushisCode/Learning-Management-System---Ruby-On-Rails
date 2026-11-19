class AddResumePositionToUserCourses < ActiveRecord::Migration[8.1]
  def up
    add_reference :user_courses,
                  :current_lesson,
                  type: :uuid,
                  foreign_key: { to_table: :lessons },
                  index: true
    add_column :user_courses, :current_page_number, :integer
  end

  def down
    remove_column :user_courses, :current_page_number
    remove_reference :user_courses,
                     :current_lesson,
                     type: :uuid,
                     foreign_key: { to_table: :lessons },
                     index: true
  end
end
