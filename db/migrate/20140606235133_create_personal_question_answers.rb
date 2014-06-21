class CreatePersonalQuestionAnswers < ActiveRecord::Migration
  def change
    create_table :personal_question_answers do |t|
      t.integer :personal_question_id
      t.string :answer
      t.integer :rank

      t.timestamps
    end
  end
end
