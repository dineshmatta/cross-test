##

module CreateFromUser
  extend ActiveSupport::Concern

  included do
    attr_accessor :from

    def from=(email)

      unless email.blank?

        # search using the same method as Devise validation
        from_user = User.find_first_by_auth_conditions(email: email)

        unless from_user
          from_user = User.where(email: email).first_or_create

          unless from_user
            errors.add(:from, :invalid)
          end
        end

        self.user = from_user
      end

    end

    def from
      user.email unless user.nil?
    end
  end

end
