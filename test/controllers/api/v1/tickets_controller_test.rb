##

require 'test_helper'

class Api::V1::TicketsControllerTest < ActionController::TestCase

  setup do
    @ticket = tickets(:problem)
  end

  test 'should get index' do
    sign_in users(:bob)

    get :index, params: {
      auth_token: users(:bob).authentication_token,
      format: :json
    }
    assert_response :success
    assert_not_nil assigns(:tickets)
  end

  test 'should show ticket' do
    sign_in users(:bob)

    get :show, params: {
      auth_token: users(:bob).authentication_token,
      id: @ticket.id,
      format: :json
    }
    assert_response :success
  end

  test 'should show tickets as nested resource' do
    get :index, params: {
      auth_token: users(:bob).authentication_token,
      user_email: Base64.urlsafe_encode64(users(:alice).email),
      format: :json
    }
    assert_response :success
  end

  test 'should create ticket' do
    sign_in users(:bob)
    assert_difference 'Ticket.count', 1 do
      post :create, params: {
        auth_token: users(:bob).authentication_token,
        ticket: {
        content: 'I need help',
        from: 'bob@xxxx.com',
        subject: 'Remote from API',
        priority: 'low'}, 
        format: :json
      }
    end
    assert_response :success
  end
end
