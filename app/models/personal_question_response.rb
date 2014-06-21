class PersonalQuestionResponse < ActiveRecord::Base
	belongs_to :personal_question_answer
  belongs_to :personal_profile
  has_one    :personal_question, through: :personal_question_answer

end
