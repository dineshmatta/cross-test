class SettingsController < ApplicationController

  def edit
    @tenant = Tenant.current_tenant
    authorize! :edit, @tenant
  end

  def update
    @tenant = Tenant.current_tenant
    authorize! :update, @tenant

    if @tenant.update_attributes(tenant_params)
      redirect_to tickets_url, notice: I18n.t(:settings_saved)
    else
      render 'edit'
    end
  end

  protected

  def tenant_params
    params.require(:tenant).permit(
      :default_time_zone,
      :ignore_user_agent_locale,
      :default_locale,
      :share_drafts,
      :first_reply_ignores_notified_agents,
      :notify_client_when_ticket_is_assigned_or_closed,
      :notify_user_when_account_is_created,
      :notify_client_when_ticket_is_created,
      :ticket_creation_is_open_to_the_world,
      :stylesheet_url,
      :always_notify_me,
      :work_can_wait
    )
  end

  def month_names
    @month_names = (1..12).map do |m|
      I18n.l DateTime.parse(Date::MONTHNAMES[m]),
          format: "%B"
    end
  end
  
  def day_names
    @day_names = (1..7).map do |m|
      I18n.l DateTime.parse(Date::MONTHNAMES[m])
    end
  end
end
