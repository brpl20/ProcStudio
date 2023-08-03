# frozen_string_literal: true

class Honorary < ApplicationRecord
  belongs_to :work

  enum honorary_type: {
    work: 'trabalho',
    success: 'exito',
    both: 'ambos',
    bonus: 'pro_abono'
  }
end
