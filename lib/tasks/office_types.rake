# frozen_string_literal: true

namespace :cad do
  desc 'Criação dos offices_types para serem utilizados nos escritórios'
  task office_types: :environment do
    types = %w[Advocacia Contabilidade Outro]

    types.each do |t|
      OfficeType.find_or_create_by(
        description: t.to_s
      )
    end
  end
end
