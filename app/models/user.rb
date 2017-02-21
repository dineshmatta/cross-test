##

class User < ApplicationRecord
  devise Rails.application.config.devise_authentication_strategy, :recoverable,
    :rememberable, :trackable, :validatable,:omniauthable,
    omniauth_providers: [:google_oauth2]

  has_many :tickets, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :labelings, as: :labelable, dependent: :destroy
  has_many :labels, through: :labelings
  has_many :assigned_tickets, class_name: 'Ticket',
      foreign_key: 'assignee_id', dependent: :nullify
  has_many :notifications, dependent: :destroy

  belongs_to :schedule

  # identities for omniauth
  has_many :identities

  has_and_belongs_to_many :unread_tickets, class_name: 'Ticket'

  after_initialize :default_localization
  before_validation :generate_password

  accepts_nested_attributes_for :schedule

  # All ldap users are agents by default, remove/comment this method if this
  # is not the intended behavior.
  def ldap_before_save
    self.agent = true
  end

  scope :agents, -> {
    where(agent: true)
  }

  scope :by_agent, ->(value) {
    where(agent: value)
  }

  scope :ordered, -> {
    order(:email)
  }

  scope :by_email, ->(email) {
    where('LOWER(email) LIKE ?', '%' + email.downcase + '%')
  }

  scope :search, ->(term) {
    if !term.nil?
      term.gsub!(/[\\%_]/) { |m| "!#{m}" }
      term = "%#{term.downcase}%"
      where('LOWER(email) LIKE ? ESCAPE ?', term, '!')
    end
  }

  def name
    super || name_from_email_address
  end

  def is_working?
    #sanity checks for default behaviour
    return true unless schedule_enabled # this is the default behaviour
    return true if schedule.nil? # this is the default behaviour
    schedule.is_during_work?(Time.now.in_time_zone(self.time_zone))
  end

  def name_from_email_address
    email.split('@').first
  end

  def self.agents_to_notify
    User.agents
        .where(notify: true)
  end

  # Does the email address of this user belong to the ticket system
  # itself? For example, there might be a user corresponding to
  # support@example.com.
  #
  # This check is needed to prevent email loops. We do not want to
  # deliver to those email addresses, since they would be received
  # by the ticket system, again, creating an email loop.
  #
  def ticket_system_address?
    User.ticket_system_addresses.pluck(:id).include? self.id
  end

  # Return all users that correspond to email addresses belonging
  # to the ticket system, e.g. support@example.com.
  #
  def self.ticket_system_addresses
    User.where(email: EmailAddress.pluck(:email))
  end

  def client?
    not agent?
  end

  def default_localization
    self.time_zone = Tenant.current_tenant.default_time_zone if time_zone.blank?
    self.locale = Tenant.current_tenant.default_locale if locale.blank?
  end

  def generate_password
    if encrypted_password.blank?
      self.password = Devise.friendly_token.first(12)
    end
  end
end
