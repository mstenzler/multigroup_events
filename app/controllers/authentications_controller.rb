class AuthenticationsController < ApplicationController
  def index
    @authentications = current_user.authentications if current_user
    @authentications ||= []
  end

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = "Signed in successfully"
      sign_in(authentication.user, CONFIG[:default_remember_me] || false)
      redirect_to authentication.user
    elsif current_user
      current_user.authentications.create(provider: omniauth['provider'], uid: omniauth['uid'])
      flash[:notice] = "Authentication Succesfull"
      redirect_to authentications_url
    else
      user = User.new
      user.apply_omniauth(omniauth)
      #user.authentications.build(provider: omniauth['provider'], uid: omniauth['uid'])
      if user.save
        flash[:notice] = "Signed in successfully"
        sign_in(user, CONFIG[:default_remember_me] || false)
        redirect_to user
      else
        session[:omniauth] = omniauth.except('extra')
        logger.debug("About to redirect to signup_url. session = #{session[:omniauth].inspect}")
        redirect_to signup_url
      end
    end
  
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    puts "About to destroy authentication #{@authentication.inspect}"
    @authentication.destroy
    redirect_to authentications_url, :notice => "Successfully destroyed authentication."
  end
end
