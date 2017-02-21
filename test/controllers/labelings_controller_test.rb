##

require 'test_helper'

class LabelingsControllerTest < ActionController::TestCase

  setup do
    @labeling = labelings(:bug_ticket)
    sign_in users(:alice)
  end

  test 'should create labeling' do

    assert_difference 'Labeling.count' do

      post :create, format: :js, params: {
        labeling: {
          labelable_id: tickets(:problem).id,
          labelable_type: 'Ticket',
          label: {
            name: 'Hello'
          }
        }
      }

      assert_response :success
    end
  end

  test 'should remove labeling' do
    assert_difference 'Labeling.count', -1 do
      delete :destroy, params: { id: @labeling, format: :js }

      assert_response :success
    end
  end
end
