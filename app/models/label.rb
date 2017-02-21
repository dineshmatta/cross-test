
##

# labels attached via labelings to users or tickets
class Label < ApplicationRecord
  has_many :labelings, dependent: :destroy
  has_many :users, through: :labelings, source: :labelable, source_type: 'User'

  after_initialize :assign_random_color

  COLORS = [
    '#de6262',
    '#65a8dd',
    '#6fc681',
    '#9d61dd',
    '#6370dd',
    '#dca761',
    '#a86f72',
    '#759d91',
    '#727274'
  ]

  scope :ordered, lambda {
    order(:name)
  }

  scope :viewable_by, lambda { |user|
    if !user.agent? || user.labelings.count > 0
      where(id: user.label_ids)
    end
  }

  def assign_random_color
    self.color = Label::COLORS.sample if color.blank?
  end
end
