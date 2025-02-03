# frozen_string_literal: true

class S3Service
    def initialize
        Aws.config.update(
        {
            region: 'us-west-2',
            credentials: Aws::Credentials.new(
                ENV.fetch('AWS_ID', nil),
                ENV.fetch('AWS_SECRET_KEY', nil)
            )
        }
        )

        @aws_client = Aws::S3::Client.new
        @bucket = 'prcstudio3herokubucket/base'
        @key = 'file.docx'
    end

    def get_document
        aws_client.get_object(bucket: 'prcstudio3herokubucket', key: 'base/procuracao_simples.docx')
    end

    def upload_document; end

    private

    def retrieve_document
        aws_doc = aws_client.get_object(bucket: 'prcstudio3herokubucket', key: 'base/procuracao_simples.docx')
        Docx::Document.open(aws_doc.body)
    end

    def save_and_upload(doc)
        doc.save(Rails.root.join('tmp/procuração_teste.docx').to_s)
    end
end
