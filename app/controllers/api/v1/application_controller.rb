class Api::V1::ApplicationController < ActionController::Base
  include MultiTenancy
  
  protect_from_forgery with: :null_session

  before_action :authenticate_user_from_token!
  before_action :load_tenant

  check_authorization

  def authenticate_user_from_token!
    user_token = params[:auth_token].presence
    user = user_token && User.where(authentication_token: user_token.to_s).first

    if user && Devise.secure_compare(user.authentication_token, params[:auth_token])
      sign_in user, store: false
    else
      render nothing: true, status: :unauthorized
    end
  end
end
