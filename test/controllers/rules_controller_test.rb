##

require 'test_helper'

class RulesControllerTest < ActionController::TestCase

  setup do
    @alice = users(:alice)
    @bob = users(:bob)

    @rule = rules(:assign_when_ivaldi)
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
      id: @rule
    }
    assert_response :success
  end

  test 'should update' do
    sign_in @alice

    put :update, params: {
      id: @rule, rule: {
        filter_field: 'subject',
      }
    }
    assert_equal 'subject', assigns(:rule).filter_field
    assert_redirected_to rules_url
  end

  test 'should get new' do
    sign_in @alice

    get :new
    assert_response :success
  end

  test 'should create' do
    sign_in @alice

    assert_difference 'Rule.count' do
      post :create, params: {
        rule: {
          filter_field: @rule.filter_field,
          filter_operation: @rule.filter_operation,
          filter_value: @rule.filter_value,
          action_operation: @rule.action_operation,
          action_value: @rule.action_value,
        }
      }

      assert_redirected_to rules_url
    end
  end

  test 'should remove rule' do
    sign_in @alice

    assert_difference 'Rule.count', -1 do
      delete :destroy, params: {
        id: @rule
      }

      assert_redirected_to rules_url
    end

  end

end
