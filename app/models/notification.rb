##

# tracks which user was notified for a notifiable object
class Notification < ApplicationRecord
  belongs_to :notifiable, polymorphic: true
  belongs_to :user
end
