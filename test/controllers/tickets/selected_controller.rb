##

require 'test_helper'

module Tickets
  # tests for interaction with selected tickets
  class SelectedControllerTest < ActionController::TestCase

    setup do
      sign_in users(:alice)
    end

    test 'should update selected ticket status' do
      request.env['HTTP_REFERER'] = tickets_url

      assert_equal 2, Ticket.open.count

      assert_difference 'Ticket.closed.count', 2 do
        patch :update, id: Ticket.open.pluck(:id), ticket: { status: 'closed' }
      end

      assert_equal 0, Ticket.open.count
    end

    test 'should not give error when id is missing' do
      request.env['HTTP_REFERER'] = tickets_url

      patch :update

      assert_redirected_to tickets_url
    end
  end
end
