##

# replies to tickets, made by a user, possibly with attachments
class Reply < ApplicationRecord
  include CreateFromUser
  include EmailMessage
  include ReplyNotifications
  prepend MergedReply

  attr_accessor :reply_to_id
  attr_accessor :reply_to_type

  validates :ticket_id, :content, presence: true

  belongs_to :ticket, touch: true
  belongs_to :user

  accepts_nested_attributes_for :ticket

  scope :chronologically, -> { order(:created_at) }
  scope :with_message_id, lambda {
    where.not(message_id: nil)
  }

  scope :without_drafts, -> {
    where(draft: false)
  }

  scope :unlocked_for, ->(user) {
    joins(:ticket)
        .where('locked_by_id IN (?) OR locked_at < ?',
            [user.id, nil], Time.zone.now - 5.minutes)
  }

  scope :without_status_replies, -> {
    where.not(type: "StatusReply")
  }

  def reply_to
    reply_to_type.constantize.where(id: self.reply_to_id).first if reply_to_type
  end

  def reply_to=(value)
    self.reply_to_id = value.id
    self.reply_to_type = value.class.name
  end

  def other_replies
    ticket.replies.where.not(id: id)
  end

  def first?
    reply_to_type == 'Ticket'
  end
end
