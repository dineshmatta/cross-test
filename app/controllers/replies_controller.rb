class RepliesController < ApplicationController

  load_and_authorize_resource

  def new
    @reply.assign_attributes(reply_params)
  end

  def create
    # store attributes and reopen ticket
    @reply = Reply.new({
        ticket_attributes: {
            status: 'open',
            id: reply_params[:ticket_id]
          }
    }.merge(reply_params.to_h))

    save_reply_and_redirect
  end

  def update
    @reply.assign_attributes(reply_params)
    save_reply_and_redirect
  end

  def show
    respond_to do |format|
      format.eml do
        begin
          send_file @reply.raw_message.path(:original),
              filename: "reply-#{@reply.id}.eml",
              type: 'text/plain',
              disposition: :attachment
        rescue => e
          print e.inspect
          raise ActiveRecord::RecordNotFound
        end
      end
    end
  end

  protected

  def save_reply_and_redirect
    if @reply.draft? && Tenant.current_tenant.share_drafts?
      @reply.user_id = nil
    else
      @reply.user_id = current_user.id
      @reply.created_at = Time.now
    end
    begin
      if @reply.draft?
        original_updated_at = @reply.ticket.updated_at

        @reply.save

        # don't screw up the ordering of inbox by resetting updated_at
        @reply.ticket.update_column :updated_at, original_updated_at

        redirect_to @reply.ticket, notice: I18n::translate(:draft_saved)
      else
        Reply.transaction do
          @reply.save!
          @reply.notification_mails.each(&:deliver_now)
        end

        redirect_to @reply.ticket, notice: I18n::translate(:reply_added)
      end
    rescue => e
      Rails.logger.error 'Exception occured on Reply transaction!'
      Rails.logger.error "Message: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.join("\n")}"
      @outgoing_addresses = EmailAddress.verified.ordered
      render 'new'
    end
  end

  def reply_params
    attributes = params.require(:reply).permit(
        :content,
        :ticket_id,
        :message_id,
        :user_id,
        :content_type,
        :draft,
        :internal,
        notified_user_ids: [],
        attachments_attributes: [
          :id,
          :_destroy,
          :file
        ],
        ticket_attributes: [
          :id,
          :to_email_address_id,
          :status,
        ]
    )

    unless can?(:update, Ticket.find(attributes[:ticket_id]))
      attributes.delete(:ticket_attributes)
    end

    attributes
  end

end
