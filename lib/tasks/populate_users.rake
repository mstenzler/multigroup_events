namespace :db do
	desc "Erase and fill database with users"
  task :populate_users => :environment do
  	require 'populator'
    require 'faker'
    require 'random_data'


#    domain_name = "nexuscafedev.com"
#    site = Site.find_by_domain_name(domain_name)
    age_display_types = ["Hidden", "Number", "Range"]
    age_hidden = age_display_types[0]
    age_number = age_display_types[1]
    age_range = age_display_types[2]

    height_display_types = PersonalProfile::HEIGHT_DISPLAY_TYPES
    height_feet_inches = PersonalProfile::HEIGHT_DISPLAY_FEET_INCHES

    question_ids = Array.new(18).fill {|i| i+1}
    question_answer_ids = Array.new(18)
    question_ids.each_with_index do |id, ind|
    	question_answer_ids[ind] = PersonalQuestionAnswer.find_all_by_personal_question_id(id).collect {|obj| obj.id }
#       puts "Ind: #{ind} - Id: #{id} : question_answer_ids[#{ind}] = #{question_answer_ids[ind].join(", ")}"
    end
    male_heights = [65,66,67,68,69,70,71,72,73,74,75,76]
    female_heights = [59,60,61,62,63,64,65,66,67,68,69]
    time_zone = 'Eastern Time (US & Canada)'

    US_country = GeoCountry.find_by_country_code("US")

    Hoboken_area = GeoArea.find_by_state_code_and_zip("NJ", "07030")
    geo_areas = GeoArea.where("geo_country_id = ? and  (state_code IN('NJ', 'NY'))", US_country.id)

    geo_area_ids = []
    geo_areas.each do |ga|
    	geo_area_ids << ga.id
    end
    geo_area_size = geo_area_ids.size

    [User, Profile, PersonalProfile, PersonalQuestionResponse, PersonalQuestionWant].each(&:delete_all)

    User.populate 1 do |u|
#      u.login_name = 'mike'
      u.username = 'mike'
#      u.login_name_display = 'Mike'
      u.name = 'Mike Stenzler'
      u.email = 'mike@nexuscafe.com'
      u.gender = 'Male'
      u.time_zone = time_zone
#      u.validation_code = 'DGDAFSAGERE'
      #u.auth_token = 'DGDAFSAGERE'
      #u.validation_token = 'DGDAFSAGERE'
      u.ip_address_created = '1.0.0.1'
      u.ip_address_last_modified = '1.0.0.1'
#      u.password = 'foobar'
      u.password_digest = BCrypt::Password.create('foobar')
      u.birthdate = 35.years.ago
      u.age = calculate_age(u.birthdate)
      u.age_display_type = age_number
      u.geo_country_id = US_country.id
#      u.geo_datum_id = 826243
      u.geo_area_id = Hoboken_area.id
#      u.status_code_id = 2
      u.created_at = 2.years.ago..Time.now
      u.last_login_at = u.created_at
      u.updated_at = u.created_at
      u.is_verified = 1
      u.email_validated = 1
      u.email_validated_at = 2.weeks.ago
      u.admin = 1
      u.avatar_type = "Upload"
#      obj_arr = []
#      [3,5,2].each do |o_id|
#        obj_arr << Objective.find(o_id)
#      end
#      u.objectives=obj_arr

#      sites.each do |cs|
##        SiteUser.populate 1 do |su|
##          puts "Creating SiteUser for user: #{u.username}"
##          su.user_id = u.id
##          su.site_id = site.id
##          su.created_at = u.created_at
##          su.updated_at = u.created_at
##          su.last_logged_in_at = u.created_at
##        end
#      end
      Profile.populate 1 do |profile|
        profile.user_id = u.id
#        profile.site_id = site.id
        profile.short_description = max_length(Populator.sentences(1..3).titleize, 255)
        profile.long_description = Populator.sentences(4..10).titleize
        profile.created_at = u.created_at
        profile.updated_at = u.created_at
      end
      PersonalProfile.populate 1 do |pp|
        pp.user_id = u.id
#        pp.site_id = site.id
        pp.about = Populator.words(10..40).titleize
        pp.height_inches = 72
        pp.height_display_type = height_feet_inches
        pp.looking_for = Populator.words(10..40)
        pp.min_height_inches = 57
        pp.max_height_inches = 64
        pp.wanted_genders_mask = 2
        pp.min_age = 24
        pp.max_age = 40
#        [2,6,9,15,23,32,33,39,41,49,58,65,75,97,99,103,123,126,133,134].each do |qa_id|
        [7,23,29,37,46,51,56,63,73,80,89,112,114,118,140,143].each do |qa_id|
          PersonalQuestionResponse.populate 1 do |pqr|
            pqr.personal_profile_id = pp.id
            pqr.personal_question_answer_id = qa_id
            pqr.created_at = u.created_at
            pqr.updated_at = u.created_at
          end
        end
#        [2,6,7,8,9,15,33,39,40,41,42,65,102,103,115].each do |qaw_id|
        [2,6,7,8,10,12,13,19,23,28,29,33,44,45,46,47,51].each do |qaw_id|
          PersonalQuestionWant.populate 1 do |pqw|
            pqw.personal_profile_id = pp.id
            pqw.personal_question_answer_id = qaw_id
            pqw.created_at = u.created_at
            pqw.updated_at = u.created_at
          end
        end
      end
    end

    #User.all.each { |user| user.avatar = File.open(Dir.glob(File.join(Rails.root, 'sampleimages', '*')).sample); user.save! }
    mike = User.find_by_username('mike')
   # default_gallery = mike.get_default_profile_gallery
#    new_photo = Photo.new
#    new_photo.image = File.open(File.join(Rails.root, 'sampleimages/me/mike.jpeg'))
#    new_photo.save!
    src = File.join(Rails.root, 'sampleimages/me/mike.jpeg')
    src_file = File.new(src)
    mike.avatar = src_file
#    mike.avatar.store!(File.open(File.join(Rails.root, 'sampleimages/me/mike.jpeg')) )
    mike.save!(:validate => false)
    #AvatarUploader.create!(:user => mike, image: File.open(File.join(Rails.root, 'sampleimages/me/mike.jpeg')))
    #mike.save(:validate => false)

#    abort("testing")

    User.populate 10 do |u|
      fname = Faker::Internet.user_name + "_" + Random.number(10000).to_s
      fname.gsub!("\.", "_")
#      u.login_name = fname
      u.username = max_length(fname,24)
#      u.login_name_display = u.login_name.titleize
      u.name = Faker::Name.first_name + "." + Faker::Name.last_name
      u.email = Faker::Internet.email
      u.gender = ['Male', 'Female']
      u.time_zone = time_zone
#      u.validation_code = 'DGDAFSAGEREDFAS'
#      u.password = 'foobar'
#      u.auth_token = 'DGDAFSAGERE'
#      u.validation_token = 'DGDAFSAGERE'
#      u.ip_address_created = '1.0.0.1'
      u.ip_address_last_modified = '1.0.0.1'
      u.password_digest = BCrypt::Password.create('foobar')
      u.birthdate = 60.years.ago..22.years.ago
      u.age = calculate_age(u.birthdate)
      u.age_display_type = age_display_types
      u.avatar_type = "Upload"
#      u.geo_country_id = 233
#      u.geo_datum_id = geo_data_ids[Random.number(geo_data_size)]
      u.geo_country_id = US_country.id
      u.geo_area_id = geo_area_ids[Random.number(geo_area_size)]
 #     u.status_code_id = 2
      u.created_at = 2.years.ago..Time.now
      u.last_login_at = u.created_at
      u.updated_at = u.created_at
      u.is_verified = 1
      u.email_validated = 1
      u.email_validated_at = 2.weeks.ago..Time.now 
      puts "creating user #{u.username}. email = #{u.email}"

      Profile.populate 1 do |profile|
        profile.user_id = u.id
        profile.short_description = max_length(Populator.sentences(1..3).titleize, 255)
        profile.long_description = Populator.sentences(4..9).titleize
        profile.created_at = u.created_at
        profile.updated_at = u.created_at
      end
      PersonalProfile.populate 1 do |pp|
        pp.user_id = u.id
        pp.about = Populator.sentences(3..12).titleize
        pp.height_inches = (u.gender == 'Male') ? male_heights[Random.number(male_heights.size)] : female_heights[Random.number(female_heights.size)]
        pp.height_display_type = height_display_types
        pp.looking_for = Populator.sentences(5..14)
        pp.min_height_inches = u.gender == 'Male' ? pp.height_inches - Random.number(3..6) : pp.height_inches - Random.number(-5..3)
        pp.max_height_inches = u.gender == 'Male' ? pp.height_inches + Random.number(0..3) : pp.height_inches + Random.number(5..11)
        pp.wanted_genders_mask = (u.gender == 'Male' ? 2 : 1)
        pp.min_age = u.gender == 'Male' ? u.age - Random.number(4..12) : u.age - Random.number(-12..5)
        pp.max_age = u.gender == 'Male' ? pp.min_age + Random.number(6..14) : pp.min_age + Random.number(8..15)
#        [2,6,9,15,23,32,33,39,41,49,58,65,75,97,99,103,123,126,133,134].each do |qa_id|
        question_answer_ids.each do |id_arr|
          PersonalQuestionResponse.populate 1 do |pqr|
            pqr.personal_profile_id = pp.id
            pqr.personal_question_answer_id = id_arr[Random.number(id_arr.size)]
            pqr.created_at = u.created_at
            pqr.updated_at = u.created_at
#            puts "user #{pp.user_id} : setting question_answer_id = #{pqr.question_answer_id}}. id_arr.size = #{id_arr.size}"
          end
        end
#        [2,6,7,8,9,15,33,39,40,41,42,65,102,103,115].each do |qaw_id|
        question_answer_ids.each do |id_arr|
          local_id_arr = dclone(id_arr)
          num_times = Random.number(local_id_arr.size)
          1.upto(num_times) do |i|
            rand_ind = Random.number(local_id_arr.size)
            new_id = local_id_arr[rand_ind]
            local_id_arr.delete_at(rand_ind)
            PersonalQuestionWant.populate 1 do |pqw|
              pqw.personal_profile_id = pp.id
              pqw.personal_question_answer_id = new_id
              pqw.created_at = u.created_at
              pqw.updated_at = u.created_at
            end
          end
        end
      end
    end

#    User.all.each { |user| user.avatar = File.open(Dir.glob(File.join(Rails.root, 'sampleimages', '*')).sample); user.save! }

    User.all.each do |user|
      puts "Adding avatar for user #{user.username}. current avatar = '#{user.avatar}'"
      puts "is_blank? = #{user.avatar.blank?}, is_nil? = '#{user.avatar.nil?}', is_true = #{user.avatar ? 'true' : 'false'}"
      if user.avatar.blank?
        puts "No Avatar id. proceeding"
        filename = (user.gender == 'Male') ? 'sampleimages/men' : 'sampleimages/women'
#        default_gallery = user.get_default_profile_gallery
#        new_photo = Photo.new
#        new_photo.image = File.open(Dir.glob(File.join(Rails.root, filename, '*')).sample)
         src = Dir.glob(File.join(Rails.root, filename, '*')).sample
         puts "src = '#{src}'"
         new_photo = File.new(src)
#        new_photo.save!
        user.avatar = new_photo
        user.save!(:validate => false)
      else
      	puts "Skiping avatar for user #{user.username}"
      end
    end
  end

  def calculate_age(birthdate)
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

  def dclone(ob)
    Marshal.load(Marshal.dump(ob))
  end

  def max_length(text, max_chars)
  	ret = text
  	if text.length > max_chars
  		ret = text[0,max_chars]
  	end
  	ret
  end
end
