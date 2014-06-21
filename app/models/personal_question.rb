class PersonalQuestion < ActiveRecord::Base
	has_many :personal_question_answers

  LABEL_TO_ID = Hash[*(self.all.collect { |p| [p.label, p.id] }).flatten ]

  LABEL_TO_QUESTION = Hash[*(self.all.collect { |p| [p.label, p.question] }).flatten ]

  LABELS = self.all.order(:rank).collect { |p| p.label }
end
