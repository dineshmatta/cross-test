module Tickets
  # class to interact with all deleted tickets
  class DeletedController < ApplicationController
    def destroy
      authorize! :destroy, Ticket
      Ticket.deleted.destroy_all

      redirect_to tickets_url(status: :deleted), notice: I18n.t(:trash_emptied)
    end
  end
end
