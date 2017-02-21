##

require 'test_helper'

class SettingsControllerTest < ActionController::TestCase

  setup do

    @tenant = tenants(:main)
  end

  teardown do
    I18n.locale = :en
  end

  test 'should create e-mailtemplates' do
    sign_in users(:alice)

    # make sure there are now templates
    EmailTemplate.delete_all

    if EmailTemplate.count == 0
      assert_difference 'EmailTemplate.count', 2 do
        put :update, params: {
          id: @tenant.id, tenant: {
          notify_user_when_account_is_created: true,
          notify_client_when_ticket_is_created: true
          }
        }
      end
    end
  end

end
