class CreateLessons < ActiveRecord::Migration[8.1]
  def change
    create_table :lessons do |t|
      t.references :course, null: false, foreign_key: true
      t.string :title, null: false
      t.string :content_type
      t.integer :position, null: false

      t.timestamps
    end
    add_index :lessons, [ :course_id, :position ], unique: true
  end
end
