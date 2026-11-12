class ChangeMetadataToJsonbInLessonPages < ActiveRecord::Migration[8.1]
  def change
    change_column :lesson_pages,
                  :metadata,
                  :jsonb,
                  using: "metadata::jsonb",
                  default: {},
                  null: false
  end
end