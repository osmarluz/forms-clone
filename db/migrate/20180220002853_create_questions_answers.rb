class CreateQuestionsAnswers < ActiveRecord::Migration[5.0]
  def change
    create_table :questions_answers do |t|
      t.text :content
      t.references :answer, foreign_key: true
      t.references :question, foreign_key: true

      t.timestamps
    end
  end
end
