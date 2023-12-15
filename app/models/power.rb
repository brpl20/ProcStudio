# frozen_string_literal: true

# == Schema Information
#
# Table name: powers
#
#  id          :bigint(8)        not null, primary key
#  description :string           not null
#  category    :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Power < ApplicationRecord
  enum category: {
    # Poderes em Geral Administrativo
    admgeneral: 0,
    admspecific: 1,
    admspecificprev: 2,
    admspecifictributary: 3,
    admspecifictributaryecac: 4,
    lawgeneral: 5,
    lawspecific: 6,
    lawspecificsecret: 7,
    lawspecificcrime: 8,
    extrajudicial: 9,
    subs: 10
  }
end
