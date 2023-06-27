# frozen_string_literal: true

namespace :cad do
  desc 'Criação dos offices_types para serem utilizados nos escritórios'
  task offices: :environment do

    types.each do |t|
      Office.find_or_create_by(
        description: t.to_s
      )
    end
  end
end
