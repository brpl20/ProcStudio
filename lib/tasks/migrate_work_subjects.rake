# frozen_string_literal: true

namespace :works do
  desc 'Migrate Work subjects to LawArea'
  task migrate_subjects_to_law_areas: :environment do
    puts 'Starting migration of Work subjects to LawArea...'

    # First, ensure we have the basic law areas
    law_areas_data = [
      { code: 'ADM', name: 'Administrativo', parent: nil },
      { code: 'CIV', name: 'Cível', parent: nil },
      { code: 'CRIM', name: 'Criminal', parent: nil },
      { code: 'PREV', name: 'Previdenciário', parent: nil },
      { code: 'TRAB', name: 'Trabalhista', parent: nil },
      { code: 'TRIB', name: 'Tributário', parent: nil },
      { code: 'OUTROS', name: 'Outros', parent: nil },

      # Sub-areas for Cível
      { code: 'FAM', name: 'Família', parent: 'CIV' },
      { code: 'CONS', name: 'Consumidor', parent: 'CIV' },
      { code: 'DANO', name: 'Danos Morais', parent: 'CIV' },

      # Sub-areas for Tributário
      { code: 'ASF', name: 'Asfalto', parent: 'TRIB' },
      { code: 'ALV', name: 'Alvará', parent: 'TRIB' },
      { code: 'PIS', name: 'PIS/COFINS', parent: 'TRIB' },

      # Sub-areas for Previdenciário
      { code: 'APOT', name: 'Aposentadoria por Tempo', parent: 'PREV' },
      { code: 'APOI', name: 'Aposentadoria por Idade', parent: 'PREV' },
      { code: 'APOR', name: 'Aposentadoria Rural', parent: 'PREV' },
      { code: 'INV', name: 'Invalidez', parent: 'PREV' },
      { code: 'REV', name: 'Revisão de Benefício', parent: 'PREV' },
      { code: 'SERV', name: 'Serviços Administrativos', parent: 'PREV' },

      # Sub-area for Trabalhista
      { code: 'RECL', name: 'Reclamatória Trabalhista', parent: 'TRAB' }
    ]

    # Create or update law areas
    law_areas_data.each do |data|
      parent = data[:parent] ? LawArea.find_by(code: data[:parent], parent_area_id: nil) : nil

      area = LawArea.find_or_initialize_by(
        code: data[:code],
        parent_area_id: parent&.id,
        created_by_team_id: nil # System areas
      )

      area.update!(
        name: data[:name],
        active: true,
        sort_order: law_areas_data.index(data)
      )

      puts "✓ Created/Updated LawArea: #{area.full_name}"
    end

    # Migrate Works
    migrated_count = 0
    failed_count = 0

    Work.find_each do |work|
      next if work.law_area_id.present?

      begin
        work.migrate_subject_to_law_area!
        migrated_count += 1
        print '.'
      rescue StandardError => e
        failed_count += 1
        puts "\n✗ Failed to migrate Work ##{work.id}: #{e.message}"
      end
    end

    puts "\n\nMigration completed!"
    puts "✓ Successfully migrated: #{migrated_count} works"
    puts "✗ Failed to migrate: #{failed_count} works" if failed_count.positive?
  end
end
