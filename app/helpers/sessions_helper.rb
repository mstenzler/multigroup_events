module SessionsHelper
	def sign_in(user, remember_me=false)
    remember_token = User.new_token
    if remember_me
      cookies.permanent[:remember_token] = remember_token
    else
      cookies[:remember_token] = remember_token
    end
    user.update_attribute(:remember_token, User.make_hash(remember_token))
    self.current_user = user
  end

  def sign_out
    if current_user
      current_user.update_attribute(:remember_token,
                                    User.make_hash(User.new_token))
      self.current_user = nil
    end
    cookies.delete(:remember_token)
  end
  
  def signed_in?
    !current_user.nil?
  end

  [:logged_in?, :user_logged_in?, :user_signed_in?].each do |ali|
    alias_method ali, :signed_in?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = User.make_hash(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def current_user?(user)
    user == current_user
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url if request.get?
  end
  
end
