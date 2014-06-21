class ResetVerifyEmailsController < ApplicationController
	before_action :init_form,  only: [:new, :create]

  def new
  end

  def create
  	password = params[:password]
    if password && @user.authenticate(password)
    	@user.reset_email_validation_token
    	@user.send_email_validation_token
    	redirect_to new_user_verify_email_path(@user), notice: User::VALIDATION_CODE_RESET_MESSAGE
    else
    	@user.errors.add(:password, "Not Valid")
      render "new"
    end
  end
  
  private

    def init_form
    	@user = current_user || User.find(params[:user_id])
    end
end