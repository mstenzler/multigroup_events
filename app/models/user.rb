class User < ActiveRecord::Base
  belongs_to :geo_country
  belongs_to :geo_area
  has_one :profile
  has_one :personal_profile, -> { includes :personal_question_responses,
                                           :personal_question_wants  }

	before_save { email.downcase! }
	before_create :create_remember_token
  before_save :init_new_user
  before_save :update_age
  after_save :init_profile

  mount_uploader :avatar, AvatarUploader
  
  attr_accessor :verify_token, :unhashed_email_validation_token, :zip_code

  VALIDATION_CODE_RESET_MESSAGE = "Your email validation code has been reset and emailed to you."

  PASSWORD_RESET_TTL_HOURS = CONFIG[:password_reset_ttl_hours] || 2

  NAME_MAX_LENGTH = 32
  NAME_MIN_LENGTH = 2
  USERNAME_MAX_LENGTH = 24
  USERNAME_MIN_LENGTH = 2
  EMAIL_MAX_LENGTH = 50
  EMAIL_MIN_LENGTH = 4
	
#	validates :name, presence: true, length: { maximum: 50 }
#	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  VALID_NAME_REGEX = /\A[a-z\d\-\_\.\&\s]+\z/i
  VALID_USERNAME_REGEX = /\A[a-z]{1}[a-z\d\-\_]+\z/i
  
  AGE_DISPLAY_TYPES = ["Hidden", "Number", "Range"]

  AGE_DISPLAY_HIDDEN = AGE_DISPLAY_TYPES[0]
  AGE_DISPLAY_NUMBER = AGE_DISPLAY_TYPES[1]
  AGE_DISPLAY_RANGE = AGE_DISPLAY_TYPES[2]

  AGE_RANGE_MAP = [ 
    { min: 0, max: 17, text: "Under 18 years old"},
    { min: 18, max: 25, text: "18-25 years old"},
    { min: 26, max: 35, text: "26-35 years old"},
    { min: 36, max: 45, text: "36-45 years old"},
    { min: 46, max: 55, text: "36-55 years old"},
    { min: 56, max: 65, text: "56-65 years old"},
    { min: 66, max: 75, text: "66-75 years old"},
    { min: 76, max: 200, text: "76 years or older"}    
  ]


  VALID_GENDERS = ["Male", "Female", "Transgender", "Other"]
  MALE_VALUE = VALID_GENDERS[0]
  FEMALE_VALUE = VALID_GENDERS[1]
  TRANSGENDER_VALUE = VALID_GENDERS[2]
  OTHER_GENDER_VALUE = VALID_GENDERS[3] 

  VALID_AVATAR_TYPES = ["None", "Gravatar", "Upload"]
  NO_AVATAR = VALID_AVATAR_TYPES[0]
  GRAVATAR_AVATAR = VALID_AVATAR_TYPES[1]
  UPLOAD_AVATAR = VALID_AVATAR_TYPES[2]

  GRAVATAR_SIZE_MAP = { tiny: "50", small: "70", medium: "100", large: "150"}
  IMAGE_RESIZE_MAP = { tiny: [30, 30], small:[60, 60] , medium: [100, 100], 
                     large: [200, 200], original: [400, 400] }

   
  DEFAULT_AVATAR_DIR = CONFIG[:default_avatar_dir] || "/images/default_avatar"

  START_YEAR = 1900
  VALID_DATES = DateTime.new(START_YEAR)..DateTime.now
  CURRENT_YEAR = DateTime.now.year

 # p "IN User: CONFIG[:min_age] = '#{CONFIG[:min_age]}'. CONFIG[:max_age] = '#{CONFIG[:max_age]}'"
  MIN_AGE = CONFIG[:min_age].blank? ? nil : CONFIG[:min_age].to_i
  MAX_AGE = CONFIG[:max_age].blank? ? nil : CONFIG[:max_age].to_i 
 # p "MIN_AGE = '#{MIN_AGE}', MAX_AGE = '#{MAX_AGE}'"
  HAS_USER_EDIT_FIELDS = (CONFIG[:enable_name?] || CONFIG[:enable_gender?] || 
                          CONFIG[:enable_birthdate?] || CONFIG[:enable_time_zone?] )

#  req_name = CONFIG[:require_name?] || false
  name_can_be_blank = CONFIG[:require_name?] ? false : true
  username_can_be_blank = CONFIG[:require_username?] ? false : true
  gender_can_be_blank = CONFIG[:require_gender?] ? false : true
  birthdate_can_be_blank = CONFIG[:require_birthdate?] ? false : true
  time_zone_can_be_blank = CONFIG[:require_time_zone?] ? false : true

#  p "IN VALIDATE: gender = '#{gender}', birthdate = '#{birthdate}'"
#p "IN VALIDATE: name_can_be_blank = '#{name_can_be_blank}', CONFIG[:require_name?] = #{CONFIG[:require_name?]}'"

  has_secure_password

  validates :password, presence: true, confirmation: true, length: { minimum: 6 }, on: :create

  validates :name, allow_blank: name_can_be_blank, presence: !name_can_be_blank, 
            format: { with: VALID_NAME_REGEX },
            length: {minimum: NAME_MIN_LENGTH, maximum: NAME_MAX_LENGTH},
            if: "CONFIG[:enable_name?]"
#  p "Validates name with maximum length of #{NAME_MAX_LENGTH}"

 #   req_username = CONFIG[:require_username?] || false
 #   p "DEFINING USERNAME. username_can_be_blank = #{username_can_be_blank}"
  validates :geo_country, presence: true
  validates :zip_code, presence: true, on: :create
  validates :username, allow_blank: username_can_be_blank, presence: !username_can_be_blank, 
            format: { with: VALID_USERNAME_REGEX },
            uniqueness: { case_sensitive: false},
            length: {minimum: USERNAME_MIN_LENGTH, maximum: USERNAME_MAX_LENGTH},
            if: "CONFIG[:enable_username?]"
 
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  validates :gender, allow_blank: gender_can_be_blank, presence: !gender_can_be_blank, 
             inclusion: { in: VALID_GENDERS },
            if: "CONFIG[:enable_gender?]"
  validates :time_zone, allow_blank: time_zone_can_be_blank, presence: !time_zone_can_be_blank, 
             inclusion: { in: ActiveSupport::TimeZone.zones_map(&:name) },
            if: "CONFIG[:enable_time_zone?]"

  if CONFIG[:enable_birthdate?]
#    p "IN enable_birthdate validation. MIN_AGE = #{MIN_AGE}. birthdate_can_be_blank = #{birthdate_can_be_blank}"
    date_hash = { allow_blank: birthdate_can_be_blank }
    if !MIN_AGE.nil?
      date_hash.merge!(before: Proc.new { MIN_AGE.years.ago }, before_message: "must be at least #{MIN_AGE} years old")
    end
    if !MAX_AGE.nil?
      date_hash.merge!(on_or_after: Proc.new{ MAX_AGE.years.ago }, on_or_after_message: "Cannot be more than #{MAX_AGE} years old")
    end
    validates_date :birthdate,  date_hash
  end

  def User.username_taken?(uname)
    where(username: uname).take ? true : false
  end
  
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def User.make_hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
  
  def User.build_default_avatar_url(opts={})
    size = opts[:size] || nil
    gender = opts[:gender] || nil
    filename = size.nil? ? "avatar.png" : "#{size.to_s.downcase}_avatar.png"
    if gender.nil?
      "#{DEFAULT_AVATAR_DIR}/default/{filename}"
    else
      "#{DEFAULT_AVATAR_DIR}/#{gender.to_s.downcase}/#{filename}" 
    end
  end

  def User.display_age_range(age, map = AGE_RANGE_MAP)
    ret = ""
    logger.debug("map = #{map.inspect}")
    map.each do |map_item|
      logger.debug("map_item = #{map_item.inspect}")
      logger.debug("age = '#{age}', min = '#{map_item[:min]}', max = '#{map_item[:max]}'")
      if age >= map_item[:min] && age <= map_item[:max] 
        ret = map_item[:text]
        break
      end
    end
    ret
  end

  def display_age_range
    self.class.display_age_range(age)
  end

  def display_age
    ret = ""
    case self.age_display_type
    when AGE_DISPLAY_HIDDEN
      ret = "Private"
    when AGE_DISPLAY_NUMBER
      ret = self.age
    when AGE_DISPLAY_RANGE
      ret = display_age_range
    else
      raise "No valid display age: #{self.age_display_type} in display_age"
    end
    ret
  end

  def display_location
    self.geo_area.display
  end

  def to_param
    self.username
  end

  def zip_code
    @zip_code || geo_area.try(:zip_code)
  end

  def self.find(identifier)
    self.find_by_username(identifier)
  end

  def init_unvalidated_email
    if CONFIG[:verify_email?]
      token = User.new_token
  #    p "IN INIT. token = #{token}"
      self.unhashed_email_validation_token = token
      self.email_validation_token = User.make_hash(token)
      self.email_validated = false
    end
    self.email_changed_at = Time.zone.now
    self.email.downcase!
  end

  def reset_email(new_email)
    self.email = new_email
    init_unvalidated_email
    save!
  end

  def reset_email_validation_token(overide_token=nil)
    #helpful for testing
    token = overide_token.nil? ? User.new_token : overide_token
    self.unhashed_email_validation_token = token
    hashed_token = User.make_hash(token)
    self.email_validation_token = hashed_token
    self.email_validated = false
    { token: token, hashed_token: hashed_token}
  end

  def send_email_validation_token
    unless self.email_validation_token && self.unhashed_email_validation_token
      raise "email_validation_token is not set when attempting to email the validation code"
    end
    UserMailer.email_validation_token(self).deliver
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def set_create_ip_addresses(adr)
    self.ip_address_created = self.ip_address_last_modified = adr
  end
  
  def validate_email
    self.update_attribute :email_validated, true
  end
  
  def generate_token(column, use_hash=false)
    begin
      token = use_hash ? User.make_hash(User.new_token) : User.new_token
      self[column] = token
    end while User.exists?(column => self[column])
  end

  def avatar_url(size=nil)
    size = size.to_sym if (!size.nil? && size.class != Symbol)
    ret = nil

    logger.debug("IN avatar_url. avatar_type = '#{avatar_type}'")
    case avatar_type
    when GRAVATAR_AVATAR
      ret = gravatar_url(self, GRAVATAR_SIZE_MAP[size])
    when UPLOAD_AVATAR 
      logger.debug("In UPLOAD_AVATAR. avatar = #{avatar}. avatar.blank = #{avatar.blank?}")
      if !avatar.nil?
        logger.debug("setting ret to uploaded avatar image")
        ret = avatar.url(size)
      else
        logger.debug("Using default avatar image")
        ret = default_avatar_url(size)
      end
    else
      ret = default_avatar_url(size)
    end
    ret.to_s
  end

  def has_avatar?
    ([GRAVATAR_AVATAR, UPLOAD_AVATAR].include? avatar_type) && !avatar.blank?
  end

  def default_avatar_url(size=:small)
    if CONFIG[:use_avatar_gender_default?]
      case gender
      when MALE_VALUE
        User.build_default_avatar_url(size: size, gender: MALE_VALUE)
      when FEMALE_VALUE
        User.build_default_avatar_url(size: size, gender: FEMALE_VALUE)
      else
        User.build_default_avatar_url(size: size, gender: OTHER_GENDER_VALUE)
      end
    else
      User.build_default_avatar_url(size: size)
    end
  end

=begin
  def update_age(do_save=false)
    new_age = calculate_age
    Rails.logger.debug("IN update_age. new_age = #{new_age.inspect}")
    self.age = new_age
    self.age_last_checked = Time.zone.now
    if do_save
      self.save(:validate => false)
    end
    new_age
  end

  def update_age!
    update_age(true)
  end
=end

  def personal_enabled?
    (self.profile && self.profile.enable_personal) ? true : false
  end

  def enable_personal_profile
    self.transaction do
      self.profile.update_attribute(:enable_personal, true)
      unless self.personal_profile
        self.create_personal_profile
      end
    end
    return true
  end

  def disable_personal_profile
    self.profile.update_attribute(:enable_personal, false)
  end

  private

    def create_remember_token
      self.remember_token = User.make_hash(User.new_token)
    end

    def create_validation_token
      self.validation_token = User.make_hash(User.new_token)
    end

    def init_new_user
      self.avatar_type ||= NO_AVATAR
      self.age_display_type ||= AGE_DISPLAY_NUMBER
      proccess_geo_area unless self.geo_area
      if new_record?
        init_unvalidated_email
      end
    end

    def proccess_geo_area
      unless (self.geo_country_id && self.zip_code)
        raise "Error. Tring to proccess geo_area without a country_id & zip"
      end
      geo_area = GeoArea.get_or_create_geo_area(self.geo_country_id, self.zip_code)


      if geo_area
        self.geo_area_id = geo_area.id
      else
        errors.add(:geo_area, "Zip code is not valid")
      end #area
    end

    def init_profile
      if new_record?
        self.build_profile
      end
    end

    def update_age(do_save=false)
      new_age = calculate_age
      Rails.logger.debug("IN update_age. new_age = #{new_age.inspect}")
#      self.age = new_age
#      self.age_last_checked = Time.zone.now
      if do_save
        #self.save(:validate => false)
        self.update_attribute(:age, new_age)
        self.update_attribute(:age_last_checked, Time.zone.now)
      end
      new_age
    end

    def update_age!
      update_age(true)
    end

    def calculate_age
      return nil if birthdate.nil?
      today = Date.today
      new_age = 0
      if (today.month > birthdate.month) or
         (today.month == birthdate.month and today.day >= birthdate.day)
        # Birthdate has happened already this year.
        new_age = today.year - birthdate.year
      else
        new_age = today.year - birthdate.year - 1
      end
      new_age
    end
end
