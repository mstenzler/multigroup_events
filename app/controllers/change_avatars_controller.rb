class ChangeAvatarsController < ApplicationController
  before_action :signed_in_user

 	def edit
	  @user = User.find_by_identity(params[:id])
	  unless @user
	  	display_error("User #{params[:id]} does not exist")
	  end
	end

 	def update
	  @user = User.find_by_identity(params[:id])
	  unless @user
	  	display_error("User #{params[:id]} does not exist")
	  	return
	  end
	  if @user.update_attributes(user_params)
	    redirect_to edit_user_url(@user), :notice => "Avatar has been changed."
	  else
	    render :edit
	  end
	end

  private

    def user_params
      params.require(:user).permit(:avatar, :avatar_type)
    end
end
