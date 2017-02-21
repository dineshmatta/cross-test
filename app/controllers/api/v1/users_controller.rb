
class Api::V1::UsersController < Api::V1::ApplicationController
  include UsersStrongParams
  load_and_authorize_resource :user

  def create
    @user = User.new(user_params)
    if @user.save
      head :created
    else
      head :bad_request
    end
  end

  def show
    unless @user = User.find_by(email: Base64.urlsafe_decode64(params[:email]))
      head :bad_request
    end
  end
end
