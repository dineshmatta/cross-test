class Api::V1::TicketsController < Api::V1::ApplicationController
  include TicketsStrongParams

  load_and_authorize_resource :ticket

  def index
    if current_user.agent && params.has_key?(:user_email)
      user = User.find_by( email: Base64.urlsafe_decode64(params[:user_email]) )
      @tickets = Ticket.by_status(:open).viewable_by(user)
    else
      @tickets = Ticket.by_status(:open).viewable_by(current_user)
    end
  end

  def show
    @ticket = Ticket.find(params[:id])
  end

  def create
    @ticket = Ticket.new(ticket_params)
    if @ticket.save
      NotificationMailer.incoming_message(@ticket, params[:message])
      head :created
    else
      head :bad_request
    end
  end
end
