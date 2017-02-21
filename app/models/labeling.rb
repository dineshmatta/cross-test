##

class Labeling < ApplicationRecord
  belongs_to :label
  belongs_to :labelable, polymorphic: true

  validates_uniqueness_of :label_id, scope: [:labelable_id, :labelable_type]
  validates :label_id, presence: true

  def initialize(attributes={})
    unless attributes[:label].blank? ||
        attributes[:label][:name].blank?

      label = Label.where(name: attributes[:label][:name]).first_or_create!

      attributes[:label_id] = label.id
    else
      attributes[:label_id] = nil
    end

    attributes.delete(:label)

    super(attributes)
  end
end
