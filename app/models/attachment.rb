##

class Attachment < ApplicationRecord
  # polymorphic relation with tickets & replies
  belongs_to :attachable, polymorphic: true

  has_attached_file :file,
      path: Tenant.files_path,
      url: '/attachments/:id/:style',
      styles: {
          thumb: {
              geometry: '50x50#',
              format: :jpg,
              # this will convert transparent parts to white instead of black
              convert_options: '-flatten'
          }
      }
  do_not_validate_attachment_file_type :file
  before_post_process :thumbnail?

  def thumbnail?

    unless file_content_type.nil?

      if !file_content_type.match(/^image/).nil? &&
          system('which convert', out: '/dev/null')

        return true
      end

      if !file_content_type.match(/pdf$/).nil? &&
          system('which gs', out: '/dev/null')

        return true
      end

    end

    return false
  end
end
