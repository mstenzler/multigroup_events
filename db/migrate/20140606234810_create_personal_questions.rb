class CreatePersonalQuestions < ActiveRecord::Migration
  def change
    create_table :personal_questions do |t|
      t.string :question
      t.string :label, :limit => 32
      t.integer :rank
      t.timestamps
    end

    add_index :personal_questions, [:label], :name => "personal_question_label_opt"
  end

end
