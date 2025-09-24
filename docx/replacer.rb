#!/usr/bin/env ruby
# frozen_string_literal: true

require 'docx'
doc = Docx::Document.open('CS-TEMPLATE.docx')

doc.paragraphs.each do |paragraph|
  paragraph.each_text_run do |text_run|
    text_run.substitute('_partner_qualification_', 'Marco Aurélio Silva, brasileiro, casado, advogado, portador do RG. 798787987 e CPF 8080135, com endereço..')
    text_run.substitute('_office_name_', 'OFFICEEEEE')
  end
end

doc.save('edited.docx')
