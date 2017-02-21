class UsersController < ApplicationController
  include UsersStrongParams

  load_and_authorize_resource :user

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    # if no password was posted, remove from params
    if params[:user][:password] == ''
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if current_user == @user
      params[:user].delete(:agent) # prevent removing own agent permissions
    end

    if @user.update_attributes(user_params)

      if current_user.agent? && current_user.labelings.count == 0
        redirect_to users_url, notice: I18n.translate(:settings_saved)
      else
        redirect_to tickets_url, notice: I18n.translate(:settings_saved)
      end

    else
      render action: 'edit'
    end
  end

  def index
    @users = User.ordered.paginate(page: params[:page])
    @users = @users.search(params[:q])
    @users = @users.by_agent(params[:agent] == '1') unless params[:agent].blank?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      user_welcome_mailer
      redirect_to users_url, notice: I18n.translate(:user_added)
    else
      render 'new'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_url, notice: I18n.translate(:user_removed)
  end

  protected

  def user_welcome_mailer
    template = EmailTemplate.by_kind('user_welcome').active.first
    tenant = Tenant.current_tenant
    if !template.nil?
      NotificationMailer.new_account(@user, template, tenant).deliver_now
    end
  end
end
