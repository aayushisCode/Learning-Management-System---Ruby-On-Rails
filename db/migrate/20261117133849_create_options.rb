class CreateOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :options, id: :uuid do |t|
      t.references :question, type: :uuid,
                              null: false,
                              foreign_key: true

      t.string :option_text, null: false

      t.integer :position, null: false

      t.timestamps
    end

    add_index :options, [:question_id, :position], unique: true,  name: "index_options_on_question_and_position"
    add_check_constraint :options,
                         "position > 0",
                         name: "options_valid_position"

    # Correct option reference from questions table
    add_foreign_key :questions,
                    :options,
                    column: :correct_option_id
  end
end
