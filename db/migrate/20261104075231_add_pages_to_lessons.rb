class AddPagesToLessons < ActiveRecord::Migration[8.1]
  def change
    add_column :lessons, :pages,
               :json,
               null: false,
               default: []
  end
end
