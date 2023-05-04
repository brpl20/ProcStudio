# frozen_string_literal: true

class ChecklisDocumentsWork < ApplicationRecord
  belongs_to :checklist_document
  belongs_to :work
end
