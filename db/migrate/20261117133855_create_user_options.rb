class CreateUserOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :user_options, id: :uuid do |t|
      t.references :user_quiz, type: :uuid,
                               null: false,
                               foreign_key: true

      t.references :question, type: :uuid,
                              null: false,
                              foreign_key: true

      t.references :option, type: :uuid,
                            null: false,
                            foreign_key: true

      t.timestamps
    end

    add_index :user_options,
              [:user_quiz_id, :question_id],
              unique: true,
              name: "index_user_options_on_quiz_and_question"
  end
end
