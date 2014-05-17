class SessionsController < ApplicationController
  before_action :init_form,  only: [:new, :create]

  def new
    if CONFIG[:check_remember_me?]
      @signin_form.remember_me = 1
    end
  end
  
  def create
    if @signin_form.submit(params[:signin_form])
      user = @signin_form.get_user
      # Sign the user in and redirect to the user's show page.
      remember_me = params[:signin_form][:remember_me] == '1' ? true : false
 #     p "Signign in remember_me = #{remember_me}, params[:remember_me] = #{params[:signin_form][:remember_me]}"
      sign_in user, remember_me
      redirect_back_or user    
    else
      render "new"
    end
  end

=begin
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # Sign the user in and redirect to the user's show page.
      sign_in user
      redirect_back_or user
    else
      flash.now[:error] = 'Invalid email/password combination' # Not quite right!
      render 'new'
    end
  end
=end

  def destroy
  	sign_out
    redirect_to root_url
  end

  private

    def init_form
      @signin_form = SigninForm.new()
#      if CONFIG[:check_remember_me?]
#        @signin_form.remember_me = 1
#        p "CHECKED!!!"
#      end
    end
end
