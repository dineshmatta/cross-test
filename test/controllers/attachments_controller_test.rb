##

class AttachmentsControllerTest < ActionController::TestCase

  setup do
    sign_in users(:alice)
    Tenant.current_domain = Tenant.first.domain
    @attachment = attachments(:default_page)
    @attachment.update_attributes!({
      file: fixture_file_upload('attachments/default-testpage.pdf', 'application/pdf')
    })
  end

  test 'should get new' do
    sign_out users(:alice)
    get :new, xhr: true
    assert_response :success
  end

  test 'should show thumb' do
    get :show, params: {
      format: :thumb,
      id: @attachment.id
    }
    assert_response :success
  end


  test 'should download original' do
    get :show, params: {
      format: :original,
      id: @attachment.id
    }
    assert_response :success
  end

end
