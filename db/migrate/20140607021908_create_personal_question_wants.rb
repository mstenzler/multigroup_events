class CreatePersonalQuestionWants < ActiveRecord::Migration
  def change
    create_table :personal_question_wants do |t|
      t.integer :personal_profile_id
      t.integer :personal_question_answer_id

      t.timestamps
    end

    add_index :personal_question_wants, [:personal_profile_id], :name => "prsnl_question_wants_opt"
  end
end
