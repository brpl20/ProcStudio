# frozen_string_literal: true

require 'faker'

# Set Faker locale
Faker::Config.locale = 'pt-BR'

# ==========================================
# TEAMS
# ==========================================
Rails.logger.debug '[TEAMS] Creating Teams...'

# Team 1 - Individual office with 1 lawyer
team1 = Team.find_or_create_by!(name: 'Escritório João') do |t|
  t.subdomain = 'joao-prado'
  Rails.logger.debug { "  [OK] Created team: #{t.name}" }
end

# Team 2 - Office with 2 lawyers
team2 = Team.find_or_create_by!(name: 'Escritório Terezinha') do |t|
  t.subdomain = 'terezinha-lawyer'
  Rails.logger.debug { "  [OK] Created team: #{t.name}" }
end

# Team 3 - Office with 3 lawyers (will have 2 offices)
team3 = Team.find_or_create_by!(name: 'Escritório Machado & Associados') do |t|
  t.subdomain = 'machado-associados'
  Rails.logger.debug { "  [OK] Created team: #{t.name}" }
end

# Team 4 - Office with 2 lawyers
team4 = Team.find_or_create_by!(name: 'Escritório Silva & Partners') do |t|
  t.subdomain = 'silva-partners'
  Rails.logger.debug { "  [OK] Created team: #{t.name}" }
end

# Team 5 - Office with 2 lawyers
team5 = Team.find_or_create_by!(name: 'Escritório Costa Advogados') do |t|
  t.subdomain = 'costa-advogados'
  Rails.logger.debug { "  [OK] Created team: #{t.name}" }
end

Rails.logger.debug '  [OK] All Teams created successfully!'