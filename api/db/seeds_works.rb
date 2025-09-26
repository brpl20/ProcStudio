# ==========================================
# SAMPLE WORKS
# ==========================================
puts '📋 Creating Sample Works...'

# Work 1 - Active Civil Case
work1 = Work.find_or_create_by!(
  folder: 'PROC-2024-001',
  team: team
) do |w|
  w.procedure = 'judicial'
  w.law_area = LawArea.find_by(code: 'FAM')
  w.number = 1001
  w.note = 'Caso de divórcio consensual'
  w.status = 'in_progress'
  w.initial_atendee = profile1.id
  w.responsible_lawyer = profile1.id
  w.partner_lawyer = profile2.id
  w.created_by_id = user1.id
  puts "  ✅ Created work: #{w.folder}"
end

# Associate customers with work
CustomerWork.find_or_create_by!(work: work1, profile_customer: profile_customer1)

# Associate user profiles with work
UserProfileWork.find_or_create_by!(work: work1, user_profile: profile1)
UserProfileWork.find_or_create_by!(work: work1, user_profile: profile2)

# Work 2 - Labor Case
work2 = Work.find_or_create_by!(
  folder: 'PROC-2024-002',
  team: team
) do |w|
  w.procedure = 'administrative'
  w.law_area = LawArea.find_by(code: 'TRAB')
  w.number = 1002
  w.note = 'Reclamação trabalhista - horas extras'
  w.status = 'in_progress'
  w.initial_atendee = profile2.id
  w.responsible_lawyer = profile2.id
  w.lawsuit = true
  w.gain_projection = 'R$ 50.000,00'
  w.created_by_id = user2.id
  puts "  ✅ Created work: #{w.folder}"
end

CustomerWork.find_or_create_by!(work: work2, profile_customer: profile_customer2)
UserProfileWork.find_or_create_by!(work: work2, user_profile: profile2)

# Work 3 - Social Security Case (Archived)
work3 = Work.find_or_create_by!(
  folder: 'PROC-2023-100',
  team: team
) do |w|
  w.procedure = 'administrative'
  w.law_area = LawArea.find_by(code: 'APOI')
  w.number = 100
  w.note = 'Aposentadoria por idade - processo concluído'
  w.status = 'archived'
  w.initial_atendee = profile1.id
  w.responsible_lawyer = profile1.id
  w.created_by_id = user1.id
  puts "  ✅ Created work: #{w.folder}"
end

CustomerWork.find_or_create_by!(work: work3, profile_customer: profile_customer3)
UserProfileWork.find_or_create_by!(work: work3, user_profile: profile1)
