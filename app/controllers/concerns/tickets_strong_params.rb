module TicketsStrongParams
  extend ActiveSupport::Concern
  protected
  def ticket_params
    if !current_user.nil? && current_user.agent?
      params.require(:ticket).permit(
        :from,
        :to_email_address_id,
        :content,
        :subject,
        :status,
        :assignee_id,
        :priority,
        :message_id,
        :content_type,
        attachments_attributes: [
          :file
        ])
    else
      params.require(:ticket).permit(
        :from,
        :content,
        :subject,
        :priority,
        :content_type,
        attachments_attributes: [
          :file
        ])
    end
  end

end
