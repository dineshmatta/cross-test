##

require 'test_helper'

class RepliesControllerTest < ActionController::TestCase

  setup do

    @ticket = tickets(:problem)
    @reply = replies(:solution)

    sign_in users(:alice)
  end

  test 'reply should always contain text' do
    # no emails should be send when invalid reply
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      assert_no_difference 'Reply.count' do

        post :create, params: {
          reply: {
            content: '',
            ticket_id: @ticket.id,
            notified_user_ids: [users(:bob).id],
          }
        }

        assert_response :success # should get a form instead of a 500
      end
    end
  end

  test 'should send correct reply notification mail' do

    # do we send a mail?
    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      post :create, params: {
        reply: {
          content: '<br><br><p><strong>this is in bold</strong></p>',
          ticket_id: @ticket.id,
          notified_user_ids: User.agents.pluck(:id),
        }
      }
    end

    mail = ActionMailer::Base.deliveries.last

    # html in the html part
    assert_match '<br><br><p><strong>this is in bold</strong></p>',
      mail.html_part.body.decoded

    # no html in the text part
    assert_match "\n\nthis is in bold\n", mail.text_part.body.decoded

    # correctly addressed
    assert_equal [User.agents.last.email], mail.to

    # correct content type
    assert_match 'multipart/alternative', mail.content_type

    # new reply link in body
    assert_match(I18n.translate(:view_new_reply), mail.text_part.body.decoded)

    # generated message id stored in db
    assert_not_nil assigns(:reply).message_id
  end

  test 'reply should have attachments' do

    assert_difference 'Attachment.count', 2 do
      post :create, params: {
        reply: {
          content: '**this is in bold**',
          ticket_id: @ticket.id,
          notified_user_ids: [users(:bob).id],
          attachments_attributes: {
            '0': { file: fixture_file_upload('attachments/default-testpage.pdf') },
            '1': { file: fixture_file_upload('attachments/default-testpage.pdf') }
          }
        }
      }
    end
  end

  test 'should be able to respond to others ticket as customer' do

    sign_out(users(:alice))
    sign_in(users(:dave))

    # do we send a mail?
    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      post :create, params: {
        reply: {
          content: 'test',
          ticket_id: @ticket.id,
          notified_user_ids: [users(:bob).id, users(:alice).id]
        }
      }
    end
    mail = ActionMailer::Base.deliveries.last
    assert_equal [users(:alice).email], mail.smtp_envelope_to
  end

  test 'should re-open ticket' do
    @ticket.status = 'closed'
    @ticket.save

    post :create, params: {
      reply: {
        content: 're-open please',
        ticket_id: @ticket.id,
      }
    }

    @ticket.reload
    assert_equal 'open', @ticket.status
  end

  test 'should get raw message' do
    @reply.raw_message = fixture_file_upload('ticket_mailer/simple')
    @reply.save!

    @reply.reload
    get :show, params: {
      id: @reply.id, format: :eml
    }
    assert_response :success
  end

end
