# frozen_string_literal: true

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
