# frozen_string_literal: true

require 'docx'

module Works
  class DocumentProcurationService < ApplicationService
    def initialize(work, document)
      @work = work
      @document = document
    end

    def call
      doc = Docx::Document.open('app/template_documents/procuracao.docx')
      doc.paragraphs.each do |paragraph|
        paragraph.each_text_run do |text|
          text.substitute('_proc_name_', 'Sasuke')
        end
      end
      doc.save("tmp/procuracao_#{@work.id}.docx")
      @document.document_docx.attach(io: File.open("tmp/procuracao_#{@work.id}.docx"), filename: "procuracao_#{@work.id}.docx")
    end
  end
end
