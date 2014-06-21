class PersonalProfilesController < ApplicationController
  before_filter :signed_in_user, :except => [:index, :show]
  before_filter :load_user_and_personal_profile, :only => [:edit, :edit_wants]

  def index
  	@users = User.paginate(page: params[:page])
  end

 # def new
 # 	@user = current_user
 # 	@personal_profile = @user.build_personal_profile
 # 	logger.debug("NEW: @personal_profile = '#{@personal_profile}'")
 # end

  def show
  	begin
	    @show_edit_links = false
	    username = params[:username] || params[:id]
	    unless username
	    	raise ArgumentError("No :username specified")
	    end
	    logger.debug("!!###  username = '#{username}'")
	    @user = User.includes(:personal_profile).find_by_username(username)
	    if @user
	    	if logged_in? && (current_user.id == @user.id)
	        	@show_edit_links = true
	      end
	#      profile_id = @user.profile.id
#	      @personal_profile = @user.personal_profile.includes(:profile, :personal_question_responses, :personal_question_wants)
#        @personal_profile = PersonalProfile.joins(:personal_question_responses).where("user_id = ?", profile_id).preload(
#        	   { :personal_question_responses => :personal_question}, 
#        	   { :personal_question_wants => :personal_question }, :personal_question).first
        @personal_profile = PersonalProfile.includes(:personal_question_responses, :personal_question_wants).where(
        	"user_id = ?", @user.id).first
 #       logger.debug("GOT @personal_profile!!!!")
 #       logger.debug("Contents of @personal_profile = #{@personal_profile.inspect}")
	      @question_answers = @personal_profile.get_collected_answers#
#	      logger.debug("GOT @question_answers!!!!")
	      @wanted_answers = @personal_profile.get_collected_wanted_answers
#	      logger.debug("GOT @wanted_answers!!! ")
	    else
	    	flash[:notice] = "User #{username} does not exist!"
	    	redirect_to :action => "index"
	    end #end if @user
	  rescue ArgumentError => err
	  	logger.error("Error in Profile#show: #{err.message}")
	  	display_error(err)
	  end
  end
  
  def edit
#  	@user = current_user
#  	logger.debug("IN EDIT. About to build personal profile. user = #{@user}")
#  	@personal_profile = @user.personal_profile || @user.build_personal_profile
#  	logger.debug("After build personal profile")
  #	if @personal_profile.new_record?
 # 		logger.debug("EDIT: @personal_profile.new_record? = true. about to save")
 # 		@personal_profile.save
 # 	end
    @personal_question_answers_hash = @personal_profile.get_collected_answer_id_hash
  end

  def edit_wants
 # 	@user = current_user
 #   @personal_profile = @user.personal_profile || @user.build_personal_profile
    @wanted_answers_hash = @personal_profile.get_collected_wanted_answer_id_hash
  end

  def update
    #@profile = Profile.find(params[:id])
    @personal_profile = current_user.personal_profile
    logger.debug("IN Update!. @personal_profile = #{@personal_profile.inspect}")
    logger.debug("About to update: profile_params = #{profile_params}")
    if @personal_profile.update_attributes(profile_params)
    	flash[:success] = "Profile updated"
      redirect_to show_personal_path(current_user)
    else
    	source = params[:source] || 'edit'
      render source
    end
	end

	private

	  def load_user_and_personal_profile
	  	@user = current_user
	  	@personal_profile = @user.personal_profile || @user.build_personal_profile
	  	@personal_profile.personal_question_responses.load
	  	@personal_profile.personal_question_answers.load
	  end

    def profile_params
      params.require(:personal_profile).permit(:about, :looking_for, :height_inches, 
      	:height_centemeters, :min_age, :max_age, :min_height_inches, 
      	:min_height_centemeters, :max_height_inches, :max_height_centemeters, 
      	:personal_question_answer_ids => [], :wanted_answer_ids => [])
    end

end