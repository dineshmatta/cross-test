module UsersStrongParams
  extend ActiveSupport::Concern
  protected
  def user_params
    attributes = params.require(:user).permit(
        :email,
        :name,
        :password,
        :password_confirmation,
        :remember_me,
        :signature,
        :agent,
        :notify,
        :time_zone,
        :locale,
        :per_page,
        :prefer_plain_text,
        :include_quote_in_reply,
        :schedule_enabled,
        label_ids: [],
        schedule_attributes: [
          :id,
          :start,
          :end,
          :monday,
          :tuesday,
          :wednesday,
          :thursday,
          :friday,
          :saturday,
          :sunday,
        ]
    )

    # prevent normal user and limited agent from changing email and role
    if !current_user.agent? || current_user.labelings.count > 0
      attributes.delete(:email)
      attributes.delete(:agent)
      attributes.delete(:label_ids)
    end

    return attributes
  end
end
