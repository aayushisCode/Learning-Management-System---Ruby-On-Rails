class CreateOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :options do |t|
      t.references :question, null: false, foreign_key: { to_table: :question_banks }
      t.string :option_text, null: false
      t.integer :position, null: false
      t.timestamps
    end
    add_index :options, [ :question_id, :position ], unique: true

    add_foreign_key :question_banks, :options, column: :correct_option_id
  end
end
