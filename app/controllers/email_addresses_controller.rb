class EmailAddressesController < ApplicationController

  load_and_authorize_resource :email_address

  def index
    @email_addresses = @email_addresses.ordered.page(params[:page])
  end

  def new
  end

  def create
    @email_address.assign_attributes(email_address_params)

    if @email_address.save
      VerificationMailer.verify(@email_address)
          .deliver_now

      redirect_to email_addresses_url, notice: I18n.t(:email_address_added)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    # allow changing everything except email field
    attributes = email_address_params
    attributes.delete(:email)

    @email_address.assign_attributes(attributes)

    if @email_address.save
      redirect_to email_addresses_url, notice: I18n.t(:email_address_modified)
    else
      render 'edit'
    end
  end

  def destroy
    @email_address.destroy
    redirect_to email_addresses_url, notice: I18n.t(:email_address_removed)
  end

  protected

  def email_address_params
    params.require(:email_address).permit(
      :name,
      :email,
      :default
    )
  end

end
