# frozen_string_literal: true

class S3UploadManager
  def self.upload_file(file, record, attachment_name, file_name = nil, content_type = nil)
    file_name ||= file.original_filename
    key = "#{Rails.env}/#{SecureRandom.uuid}_#{file_name}"

    content_type ||= file.content_type

    record.send(attachment_name).attach(io: file,
                                        filename: file_name,
                                        content_type: content_type,
                                        key: key)
  end
end
