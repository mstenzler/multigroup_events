class PersonalQuestionAnswer < ActiveRecord::Base
  has_many :personal_question_responses
  has_many :personal_question_wants
  has_many :personal_profiles,
     :through => :personal_question_responses
#  has_many :personal_question_responses
  belongs_to :personal_question

#  ANSWERS = where(:include=>[:personal_question], :order=>:rank)
  ANSWERS = order(:rank).includes(:personal_question)
#  ANSWERS_BY_LABEL = create_answer_by_label_hash

  def self.filter_by_label(label, options = {})
    ret = []
    exclude = options[:exclude] || []
    ANSWERS.collect { |a|  ret << [a.answer, a.id] if (a.personal_question.label == label)}
    ret
  end

  def self.create_answer_by_label_hash()
  	ret = {}
  	PersonalQuestion::LABELS.each do |label|
  		ret[label.to_sym] = by_label(label)
  	end
  	ret
  end

  def self.by_label(label, options = {})
  	unless label.is_a?(String)
  		label = label.to_s
  	end
#  	logger.debug("** IN by_label. label = #{label}, ANSWERS = #{ANSWERS.inspect}")

  	ret = []
  	ANSWERS.collect { |a| ret << a if (a.personal_question.label == label) }
#  	logger.debug("** ret = #{ret.inspect}")
  	ret
  end

=begin
  def self.ansers_by_label(label)
    ret = []
    answers = by_label(label)
    answers.collect ( |a| ret << a.
  end
=end

  ANSWERS_BY_LABEL = create_answer_by_label_hash

  def self.answers_by_label(label)
  	unless label.is_a?(Symbol)
  		label = label.to_sym
  	end
  	ANSWERS_BY_LABEL[label]
  end

  def self.get_question_options(label, options = {})
#    r = find(:all, :include => [:question], :conditions => ["questions.label = ?", label], :order => :rank).collect { |p| [p.answer, p.id] }
    r = filter_by_label(label)
    if (options[:include_blank])
       r.unshift(["",""])
    end
    return r
  end
end
