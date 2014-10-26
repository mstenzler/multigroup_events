class ProfilesController < ApplicationController
  before_filter :signed_in_user, :except => [:index, :show]

  def index
  	@users = User.paginate(page: params[:page])
  end

  def show
  	begin
	    @show_edit_links = false
	    username = params[:id] || params[:username]
	    unless username
	    	raise ArgumentError.new("No :username specified")
	    end
	    logger.debug("!!###  username = '#{username}'")
      @user = User.find_by_identity(username, include: :profile)
	    if @user
	    	if logged_in? && (current_user.id == @user.id)
	        	@show_edit_links = true
	      end
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
  	@user = current_user
  	logger.debug("IN EDIT: About to call build_profile. user = #{@user}")
  	@profile = @user.build_profile
  	logger.debug("After build profile")
  	if @profile.new_record?
  		logger.debug("IN EDIT: @profile is a new record: #{@profile}")
  		@profile.save
  	end
  end

  def update
    @profile = Profile.find(params[:id])
    if @profile.id != current_user.profile.id
    	display_error("Unauthorized access")
    else
	    if @profile.update_attributes(profile_params)
	    	flash[:success] = "Profile updated"
	      redirect_to show_profile_path(current_user)
	    else
	      render 'edit'
	    end
	  end
	end

	def enable_personal_on
		cu = current_user
		profile = cu.profile #Profile.find(params[:id])
		profile_id = params[:id].to_i
		logger.debug("profile_id from params = #{profile_id}, profile_id = #{profile.id}")
    if profile.id != profile_id
    	display_error("Unauthorized access")
    else
#	    if @profile.update_attribute(:enable_personal, true)
      if cu.enable_personal_profile
	    	flash[:success] = "Personal Profile Enabled"
	    	redirect_to edit_personal_profile_path
	    else
	    	flash[:error] = "Could not enable personal profile"
	    	redirect_to short_profile_path(username: cu.username)
	    end
	  end
	end

	private

    def profile_params
      params.require(:profile).permit(:short_description, :long_description)
    end

end