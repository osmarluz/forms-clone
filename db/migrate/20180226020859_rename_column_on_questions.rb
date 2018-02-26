class RenameColumnOnQuestions < ActiveRecord::Migration[5.0]
  def change
    rename_column :questions, :type, :question_type
  end
end
