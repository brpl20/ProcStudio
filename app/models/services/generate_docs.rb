# frozen_string_literal: true

class GenerateDocs
  class << self
    def config_aws
      Aws.config.update(
        {
          region: 'us-west-2',
          credentials: Aws::Credentials.new(
            ENV['AWS_ID'],
            ENV['AWS_SECRET_KEY']
          )
        }
      )
    end

    def retrieve_document
      aws_client = Aws::S3::Client.new
      aws_doc = aws_client.get_object(bucket: 'prcstudio3herokubucket', key: 'base/procuracao_simples.docx')
      Docx::Document.open(aws_doc.body)
    end

    def save_and_upload(doc)
      doc.save(Rails.root.join('tmp/procuração_teste.docx').to_s)
    end

    def prepare_documents
      config_aws

      doc = retrieve_document

      # aqui vão os templates para todos os tipos de documentos
      doc.paragraphs.each do |p|
        p.each_text_run do |tr|
          tr.substitute('_qualify_', 'Qualificação uma')
        end
      end

      save_and_upload(doc)
    end
  end
end
