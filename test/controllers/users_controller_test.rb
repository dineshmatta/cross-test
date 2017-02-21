##

require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  setup do
    @alice = users(:alice)
    @bob = users(:bob)
  end

  test 'should get index' do
    sign_in @alice

    get :index
    assert_response :success
  end

  test 'should not get index' do
    sign_in @bob

    get :index
    assert_response :unauthorized
  end

  test 'should get edit' do
    sign_in @alice

    get :edit, params: {
      id: @alice.id
    }
    assert_response :success
  end

  test 'should modify signature' do
    sign_in @alice

    put :update, params: {
      id: @alice.id, user: { signature: 'Alice' }
    }
    assert_equal 'Alice', assigns(:user).signature
    assert_redirected_to users_url
  end

  test 'customer may not become agent' do
    sign_in @bob

    assert_no_difference 'User.agents.count' do
      put :update, params: {
        id: @bob.id, user: { agent: true, signature: 'Bob' }
      }
    end
  end

  test 'customer may not create agent' do
    sign_in @bob

    assert_no_difference 'User.agents.count' do
      post :create, params: {
        user: {
          email: 'harry@getbrimir.com',
          password: 'testtest',
          password_confirmation: 'testtest',
          agent: true,
          signature: 'Harry'
        }
      }
    end

    assert_response :unauthorized
  end

  test 'should update user' do
    sign_in @alice

    assert_difference 'Labeling.count' do
      patch :update, params: {
        id: @bob.id, user: {
          email: 'test@test.test',
          label_ids: [labels(:bug).id]
        }
      }
    end

    @bob.reload

    assert_equal 'test@test.test', @bob.email
    assert_equal 1, @bob.labels.count
    assert_equal labels(:bug), @bob.labels.first

    assert_redirected_to users_url
  end

  test 'should not update user' do
    sign_in @bob

    assert_no_difference 'Labeling.count' do
      patch :update, params: {
        id: @bob.id, user: {
          email: 'test@test.test',
          label_ids: [labels(:bug).id],
          password: 'testtest',
          password_confirmation: 'testtest',
        }
      }
    end

    @bob.reload

    refute_equal 'test@test.test', @bob.email
    assert_equal 0, @bob.labels.count

    assert_redirected_to tickets_url
  end

  test 'should remove user' do
    sign_in @alice

    assert_no_difference 'User.count' do
      delete :destroy, params: {
        id: @bob.id
      }
      assert_response :unauthorized
    end

    @bob.tickets.destroy_all
    @bob.replies.destroy_all

    assert_difference 'User.count', -1 do
      delete :destroy, params: {
        id: @bob.id
      }
      assert_redirected_to users_url
    end
  end

  test 'should create a schedule' do

    @alice.schedule = nil
    @alice.save!
    @alice.reload

    sign_in @alice

    assert_nil @alice.schedule

    assert_not @alice.schedule_enabled

    assert_difference 'Schedule.count' do
      patch :update, params: {
        id: @alice.id, user: {
          email: @alice.email,
          schedule_enabled: true,
          schedule_attributes: {
            start: '08:00',
            end: '18:00'
          }
        }
      }
      assert_redirected_to users_url
    end
    @alice.reload
    assert_equal @alice.schedule.start, Time.zone.parse('08:00')
    assert_equal @alice.schedule.end, Time.zone.parse('18:00')
  end

end
