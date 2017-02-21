##

class StatusChange < ApplicationRecord
  belongs_to :ticket
  enum status: Ticket.statuses

  scope :ordered, -> {
    order(:created_at)
  }
end
