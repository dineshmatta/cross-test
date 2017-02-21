##

# helpers used for EmailTemplate views
module EmailTemplateHelper
  def check_settings(tenant, email_template)
    # prompt confirmation
    if email_template.is_active?
      response = case email_template.kind
      when 'user_welcome'
        prefix = t(:deleting_this_item_will_unset_option)
        postfix = t(
            'activerecord.attributes.tenant.notify_user_when_account_is_created')
        prefix + ' ' + postfix
      when 'ticket_received'
        prefix = t(:deleting_this_item_will_unset_option)
        postfix = t(
            'activerecord.attributes.tenant.notify_client_when_ticket_is_created')
        prefix + ' ' + postfix
      end
      return response # return the response
    end
    t(:are_you_sure) # regular confirmation
  end

  # prompt user if active is already set
  def ask_if_not_draft_exists(collection, kind)
    return if collection.empty?
    active = collection.exists?(
        ['kind = ? and draft = ?', EmailTemplate.kinds[kind], false])
    if active
      t(:already_active_template, kind: kind.humanize)
    end
  end
end
