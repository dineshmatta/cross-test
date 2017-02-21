##

require 'test_helper'

module Tickets
  # tests for interaction with deleted tickets
  class DeletedControllerTest < ActionController::TestCase

    setup do
      sign_in users(:alice)
    end

    test 'should empty trash' do

      Ticket.update_all(status: Ticket.statuses[:deleted])

      assert_difference 'Ticket.count', -3 do
        delete :destroy
        assert_redirected_to tickets_url(status: :deleted)
      end
    end
  end
end
