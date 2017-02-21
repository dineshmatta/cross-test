class EmailAddress < ApplicationRecord

  validates :email, uniqueness: true, presence: true
  has_many :tickets, foreign_key: :to_email_address_id, dependent: :nullify

  before_save :ensure_one_default
  before_create :generate_verification_token

  scope :ordered, -> { order(:default).reverse_order.order(:email) }
  scope :verified, -> { where(verification_token: nil) }

  def self.default_email
    unless EmailAddress.verified.where(default: true).first.nil?
      return EmailAddress.verified.where(default: true).first.email
    else
      Tenant.current_tenant.from
    end
  end

  def self.find_first_verified_email(addresses)
    if addresses.nil?
      nil
    else
      verified.where(email: addresses.map(&:downcase)).first
    end
  end

  def formatted
    if name.blank?
      email
    else
      "#{name} <#{email}>"
    end
  end

  protected

  def ensure_one_default
    if self.default
      EmailAddress.where.not(id: self.id).update_all(default: false) 
    end
  end

  def generate_verification_token
    self.verification_token = Devise.friendly_token
  end
end
