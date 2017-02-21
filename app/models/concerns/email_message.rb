##

module EmailMessage
  extend ActiveSupport::Concern

  included do
    has_many :attachments, as: :attachable, dependent: :destroy
    accepts_nested_attributes_for :attachments, allow_destroy: true

    has_many :attached_files, -> { where(content_id: nil) }, as: :attachable, class_name: 'Attachment'

    has_attached_file :raw_message,
        path: Tenant.files_path

    do_not_validate_attachment_file_type :raw_message
  end

  def inline_files
    attachments.where.not(content_id: nil).map do |attachment|
      [attachment.content_id, attachment.file.url(:original)]
    end.to_h
  end
end
