# frozen_string_literal: true

namespace :cad do
  desc 'Criação dos offices_types para serem utilizados nos escritórios'
  task office_type: :environment do
    types = %w[Advocacia Contabilidade]

    types.each do |t|
      OfficeType.create!(
        description: t.to_s
      )
    end
  end
end
