module Tickets
  # class to interact with all selected tickets (params[:id][...])
  class SelectedController < ApplicationController
    skip_load_and_authorize_resource

    def update
      @tickets = Ticket.where(id: params[:id])

      authorize! :update, Ticket # for empty params[:id]

      return perform_merge if merge?

      @tickets.each do |ticket|
        authorize! :update, ticket
        ticket.update_attributes(ticket_params)
      end

      redirect_to :back, notice: t(:tickets_status_modified)
    end

    protected

    def ticket_params
      params.require(:ticket).permit(:status)
    end

    def merge?
      params[:merge] == 'true'
    end

    def perform_merge
      @tickets.each do |ticket|
        authorize! :update, ticket
      end

      unless @tickets.count == 0
        merged_ticket = Ticket.merge @tickets, current_user: current_user
      end
      redirect_to merged_ticket, notice: t(:tickets_have_been_merged)
    end
  end
end

