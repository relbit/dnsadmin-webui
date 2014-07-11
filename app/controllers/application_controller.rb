class ApplicationController < AuthController
  protect_from_forgery
  
  before_filter :authenticate
  
  protected
  def authenticate
      authenticate_or_request_with_http_basic do |username, password|
          user = view_context.user_auth username, password
          
          if !user.nil?
              session[:user] = user
              return true
          end
          
          false
      end
  end
  
  def authenticated?
      defined? session[:user] and !session[:user].nil?
  end
  
  def get_user_id
      session[:user].id
  end
  
#  protected
#  def redirect_to_https(url, status = {})
#      host = DNSAdminGui::Application.config.hostname.nil? ? "" : DNSAdminGui::Application.config.hostname
#      redirect_to host + url, status
#  end
end
