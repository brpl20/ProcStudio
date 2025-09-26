# ==========================================
# JOBS (Tasks)
# ==========================================
puts '📝 Creating Jobs...'
job1 = Job.find_or_create_by!(
  description: 'Preparar petição inicial',
  work: work1
) do |j|
  j.deadline = 7.days.from_now
  j.status = 'pending'
  j.priority = 'high'
  j.comment = 'Urgente - prazo processual'
  j.team = team
  j.created_by_id = user1.id
  puts "  ✅ Created job: #{j.description}"
end

# Associate user profile with job
JobUserProfile.find_or_create_by!(job: job1, user_profile: profile1, role: 'assignee')

job2 = Job.find_or_create_by!(
  description: 'Coletar documentos do cliente',
  work: work2
) do |j|
  j.deadline = 3.days.from_now
  j.status = 'pending'
  j.priority = 'medium'
  j.profile_customer = profile_customer2
  j.team = team
  j.created_by_id = user2.id
  puts "  ✅ Created job: #{j.description}"
end

# Associate user profile with job
JobUserProfile.find_or_create_by!(job: job2, user_profile: profile3, role: 'assignee')
