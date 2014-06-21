class PersonalProfile < ActiveRecord::Base
	belongs_to :user
  has_many :personal_question_responses, dependent: :destroy
  has_many :personal_question_answers, -> { includes :personal_question },  
           through: :personal_question_responses
  accepts_nested_attributes_for :personal_question_responses, allow_destroy: true
  has_many :personal_question_wants, dependent: :destroy
  has_many :wanted_answers, 
           through: :personal_question_wants, 
           source: :personal_question_answer
  accepts_nested_attributes_for :personal_question_wants, allow_destroy: true

  require 'height_helper'
  include HeightHelper

  attr_accessor :height
  attr_accessor :height_feet
  attr_accessor :height_feet_inches
  attr_accessor :height_centemeters

  attr_accessor :min_height
  attr_accessor :min_height_feet
  attr_accessor :min_height_feet_inches
  attr_accessor :min_height_centemeters

  attr_accessor :max_height
  attr_accessor :max_height_feet
  attr_accessor :max_height_feet_inches
  attr_accessor :max_height_centemeters

  after_validation :convert_height

  WANTED_GENDERS = User::VALID_GENDERS

  HEIGHT_DISPLAY_TYPES = ["hide", "inches", "feet_inches", "centemeters", "descriptive"]

  HEIGHT_DISPLAY_HIDE = HEIGHT_DISPLAY_TYPES[0]
  HEIGHT_DISPLAY_INCHES = HEIGHT_DISPLAY_TYPES[1]
  HEIGHT_DISPLAY_FEET_INCHES = HEIGHT_DISPLAY_TYPES[2]
  HEIGHT_DISPLAY_CENTEMETERS = HEIGHT_DISPLAY_TYPES[3]
  HEIGHT_DISPLAY_DESCRIPTIVE = HEIGHT_DISPLAY_TYPES[4]

  HEIGHT_DISPLAY_DEFAULT = HEIGHT_DISPLAY_FEET_INCHES
  HEIGHT_DISPLAY_HIDDEN_TEXT = "Hidden"
  HEIGHT_DISPLAY_BLANK_TEXT = "Not Provided"

  HEIGHT_DISPLAY_DESCRIPTIVE_MALE_MAP = [ {:inches => 66, :op => "<=", :result => "Short"},
                                          {:inches => 72, :op => "<=", :result => "Average"},
                                          {:inches => 75, :op => "<=", :result => "Tall"},
                                          {:inches => 76, :op => ">=", :result => "Very Tall"},
                                        ]
  HEIGHT_DISPLAY_DESCRIPTIVE_FEMALE_MAP = [ {:inches => 63, :op => "<=", :result => "Short"},
                                            {:inches => 67, :op => "<=", :result => "Average"},
                                            {:inches => 70, :op => "<=", :result => "Tall"},
                                            {:inches => 71, :op => ">=", :result => "Very Tall"},
                                          ]

  scope :with_wanted_gender, lambda { |wanted_gender| {:conditions => "wanted_genders_mask & #{2**WANTED_GENDERS.index(wanted_gender.to_s)} > 0"} }

  def height_description
    return nil if self.height_inches.nil?
    return "" if user.gender.blank?
    map = nil
    case user.gender
      when User.MALE_VALUE
        map = HEIGHT_DISPLAY_DESCRIPTIVE_MALE_MAP
      when User.FEMALE_VALUE
        map = HEIGHT_DISPLAY_DESCRIPTIVE_FEMALE_MAP
    end
    return "" if map.nil?
    ret = ""
    map.each do |vals|
      inches = vals[:inches]
      op = vals[:op]
      curr_inches = self.height_inches
      ret = ( eval "#{curr_inches} #{op} #{inches}") ? vals[:result] : nil
      break unless ret.nil?
    end
    ret
  end

  def height_display
    type = self.height_display_type || HEIGHT_DISPLAY_DEFAULT
    ret = ""
    case type
      when HEIGHT_DISPLAY_HIDE
        ret = HEIGHT_DISPLAY_HIDDEN_TEXT
      when HEIGHT_DISPLAY_INCHES
        ret = (self.height_inches.nil? || self.height_inches == 0) ? HEIGHT_DISPLAY_BLANK_TEXT : self.height_inches
      when HEIGHT_DISPLAY_FEET_INCHES
        ret = (self.height_inches.nil? || self.height_inches == 0) ? HEIGHT_DISPLAY_BLANK_TEXT : "#{self.height_feet}' #{self.height_feet_inches}\""
      when HEIGHT_DISPLAY_CENTEMETERS
        ret = (self.height_inches.nil? || self.height_inches == 0) ? HEIGHT_DISPLAY_BLANK_TEXT : self.height_centemeters
      when HEIGHT_DISPLAY_DESCRIPTIVE
        ret = (self.height_inches.nil? || self.height_inches == 0) ? HEIGHT_DISPLAY_BLANK_TEXT : self.height_description
    end
    ret
  end

  def wanted_genders=(wanted_genders)
    self.wanted_genders_mask = (wanted_genders & WANTED_GENDERS).map { |r| 2**WANTED_GENDERS.index(r) }.sum
  end

  def wanted_genders
    WANTED_GENDERS.reject { |r| ((wanted_genders_mask || 0) & 2**WANTED_GENDERS.index(r)).zero? }
  end

  def wanted_gender?(wanted_gender)
    wanted_genders.include? wanted_gender.to_s
  end

  def wanted_age_range(*args)
    default_none = "Any"
    delimiter = "to"
    if ( (args.size == 1) && (args[0].is_a? Hash) )
      params = args[0]
      default_none = params[:default_none] if params[:default_none]
      delimiter = params[:delimiter] if params[:delimiter]
    end
    ret = ""
    if ( (!min_age) && (!max_age))
      ret = default_none
    elsif (min_age && (!max_age))
      ret = "#{min_age} and older"
    elsif (max_age && (!min_age))
      ret = "#{max_age} and younger"
    else
      ret = "#{min_age} #{delimiter} #{max_age}"
    end
    ret
  end 

  def height_feet
    return nil if self.height_inches.nil?
    if @height_feet.nil?
      @height_feet = ((self.height_inches / 12).to_i)
    end
    @height_feet
  end

  def height_feet_inches
    return nil if self.height_inches.nil?
    if @height_feet_inches.nil?
      @height_feet_inches = ((self.height_inches % 12).to_i)
    end
    @height_feet_inches
  end

  def min_height_feet
    return nil if self.min_height_inches.nil?
    if @min_height_feet.nil?
      @min_height_feet = ((self.min_height_inches / 12).to_i)
    end
    @min_height_feet
  end

  def min_height_feet_inches
    return nil if self.min_height_inches.nil?
    if @min_height_feet_inches.nil?
      @min_height_feet_inches = ((self.min_height_inches % 12).to_i)
    end
    @min_height_feet_inches
  end


  def max_height_feet
    return nil if self.max_height_inches.nil?
    if @max_height_feet.nil?
      @max_height_feet = ((self.max_height_inches / 12).to_i)
    end
    @max_height_feet
  end

  def max_height_feet_inches
    return nil if self.max_height_inches.nil?
    if @max_height_feet_inches.nil?
      @max_height_feet_inches = ((self.max_height_inches % 12).to_i)
    end
    @max_height_feet_inches
  end
       
  def target_height_text

    min = max = nil
    if (min_height_feet && min_height_feet_inches)
      min = "#{min_height_feet}' #{min_height_feet_inches}\""
    end

    if (max_height_feet && max_height_inches)
      max = "#{max_height_feet}' #{max_height_feet_inches}\""
    end

    if (min || max)
      min ||= "unspecified"
      max ||= "unspecified"
      ret = "#{min} to #{max}"
    else
      ret = "unspecified"
    end
    ret
  end

  #after_save callback to handle question_answer_ids
  def update_answers
    changed = false
    #handle question_answer_ids
    unless answer_ids.nil?
      self.personal_question_responses.each do |r|
        r.destroy unless answer_ids.include?(r.question_answer_id.to_s)
        answer_ids.delete(r.question_answer_id.to_s)
      end
      answer_ids.each do |a|
        self.personal_question_responses.create(:question_answer_id => a) unless a.blank?
      end
      changed = true
    end
    #handle looking_for_ids
    unless looking_for_ids.nil?
      self.personal_question_wants.each do |r|
        r.destroy unless looking_for_ids.include?(r.question_answer_id.to_s)
        looking_for_ids.delete(r.question_answer_id.to_s)
      end
      looking_for_ids.each do |a|
        self.personal_question_wants.create(:question_answer_id => a) unless a.blank?
      end
      changed = true
    end
    if changed
      reload
      self.answer_ids = nil
      looking_for_ids = nil
    end
  end

  def get_collected_answers
    collect_answers(self.personal_question_answers)
  end

  def get_collected_wanted_answers
    collect_answers(self.wanted_answers)
  end

  def get_collected_answer_id_hash
  	collect_hash_of_answers(self.personal_question_answers)
  end

  def get_collected_wanted_answer_id_hash
  	collect_hash_of_answers(self.wanted_answers)
  end


  private

	  def collect_answers (answers_arr)
	    logger.debug("+++ In Collect_answers")
	    answers = {}
	    questions = {}
	    labels = []
	    answers_arr.each do |a|
	    logger.debug("+++ Answer = #{a}")
	      unless a.nil?
	      	logger.debug("About to get label")
	        label = a.personal_question.label
	        if label
	        	logger.debug("Got label #{label}, about to get question")
	          question = a.personal_question.question
	          logger.debug("Got question: #{question}, abotu to get answer")
	          answer = a.answer
	          logger.debug("Got answer: #{answer}")
	          if answers[label]
	            answers[label] << answer
	          else
	            answers[label] = [answer]
	            questions[label] = question
	            labels << label
	          end
	        end #if label
	      end #unless a.nil
	    end #answers.each

	    ret = []
	    logger.debug("+++ LABELS = #{labels}")
	    labels.each do |l|
	      if answers[l]
	        ret << { 'label' => l, 'question' => questions[l], 'answer' => answers[l]}
	      end
	    end
	    ret
	  end

	  def collect_hash_of_answers (answers_arr)
#	    logger.debug("+++ In Collect_answers")
	    answers = {}
	    answers_arr.each do |a|
	      unless a.nil?
#	      	logger.debug("About to get label")
	        label = a.personal_question.label
	        if label
#	        	logger.debug("Got label #{label}, about to get question")
	          answer = a.id
#	          logger.debug("Got answer: #{answer}")
	          if answers[label]
	            answers[label] << answer
	          else
	            answers[label] = [answer]
	          end
	        end #if label
	      end #unless a.nil
	    end #answers.each
	    answers
	  end


	  def convert_height
	#    logger.debug("PERSONAL_PROFILE: in convert_height. height_feet = #{height_feet}, height_feet_inches = #{height_feet_inches}")
	    begin
	      self.height_inches = to_inches(:feet => self.height_feet, :inches => self.height_feet_inches, :centemeters => self.height_centemeters) unless self.height_feet.nil?
	      self.min_height_inches = to_inches(:feet => self.min_height_feet, :inches => self.min_height_feet_inches, :centemeters => self.min_height_centemeters) unless self.min_height_feet.nil?
	      self.max_height_inches = to_inches(:feet => self.max_height_feet, :inches => self.max_height_feet_inches, :centemeters => self.max_height_centemeters) unless self.max_height_feet.nil?

	    rescue MissingArgumentError => error
	      self.errors.add(:height, "has not been entered")
	    rescue BadArgumentError => error
	      self.errors.add(:height, "must be a number")
	    rescue ArgumentError => error
	      self.errors.add(:height, "has a problem")
	    end
	  end
end
