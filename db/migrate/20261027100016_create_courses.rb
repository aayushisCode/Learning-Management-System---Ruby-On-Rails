class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.references :category, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :status, default: "draft"
      t.timestamps
    end
  end
end
