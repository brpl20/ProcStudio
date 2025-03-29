class S3UploadManager
    def self.upload_file(file, record, attachment_name, file_name=nil, content_type=nil)
      file_name = file.original_filename unless file_name
      file_name = "#{Rails.env}/#{file_name}"

      content_type = file.content_type unless content_type

      record.send(attachment_name).attach(io: file, filename: file_name, content_type: content_type)
    end
  end
