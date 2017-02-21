class AttachmentsController < ApplicationController

  before_action :authenticate_user!, except: [:create, :new]
  load_and_authorize_resource :attachment, except: :show

  def show
    @attachment = Attachment.find(params[:id])

    if @attachment.attachable_type == 'Ticket'
      authorize! :read, @attachment.attachable
    else
      authorize! :read, @attachment.attachable.ticket
    end

    begin
      if params[:format] == 'thumb'
        send_file @attachment.file.path(:thumb),
            type: 'image/jpeg',
            disposition: :inline
      else
        send_file @attachment.file.path,
            filename: @attachment.file_file_name,
            type: @attachment.file_content_type,
            disposition: :attachment
      end
    rescue
      raise ActiveRecord::RecordNotFound
    end
  end
end
