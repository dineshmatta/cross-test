module Tickets
  class LocksController < ApplicationController
    skip_authorization_check only: [:create, :destroy]

    def create
      @ticket = Ticket.find(params[:ticket_id])
      if can? :update, @ticket
        # don't touch updated_at
        @ticket.update_column :locked_by_id, current_user.id
        @ticket.update_column :locked_at, Time.zone.now
      end
    end

    def destroy
      @ticket = Ticket.find(params[:ticket_id])
      # if labels can be removed by this user,
      # he can also unlock tickets, because he is not limited
      if can?(:destroy, Labeling.new(labelable: @ticket))
        # don't touch updated_at
        @ticket.update_column :locked_by_id, nil
        @ticket.update_column :locked_at, nil
      end
      redirect_to ticket_path(@ticket)
    end
  end
end
