# frozen_string_literal: true

class S3Service
    def upload_document(file_path)
      file = File.open(file_path)

      blob = ActiveStorage::Blob.create_and_upload!(
        io: file,
        filename: File.basename(file_path),
        content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      )

      file.close
      blob.service_url
    end

    def get_document(document)
        document.blob.open do |file|
            file.read
        end
    end
  end
