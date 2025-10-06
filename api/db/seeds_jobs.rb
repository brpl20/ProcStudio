# frozen_string_literal: true

# ==========================================
# JOBS (Tasks)
# ==========================================
puts '[JOBS] Creating Jobs...'

# Get references from previous seed files
user1 = User.find_by(email: 'u1@gmail.com')
user2 = User.find_by(email: 'u2@gmail.com')
profile1 = UserProfile.find_by(user: user1)
profile2 = UserProfile.find_by(user: user2)
profile3 = UserProfile.find_by(user: User.find_by(email: 'u3@gmail.com'))
team = Team.find_by(subdomain: 'joao-prado')

# Get customer references
profile_customer1 = ProfileCustomer.joins(:customer).find_by(customers: { email: 'cliente1@gmail.com' })
profile_customer2 = ProfileCustomer.joins(:customer).find_by(customers: { email: 'empresa@empresa.com.br' })

# Try to get work references if they exist
work1 = Work.first
work2 = Work.second

# Create jobs with conditional work association
if work1
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
    puts "  [OK] Created job with work: #{j.description}"
  end
else
  # Create job associated with customer instead of work
  job1 = Job.find_or_create_by!(
    description: 'Preparar documentação inicial',
    profile_customer: profile_customer1
  ) do |j|
    j.deadline = 7.days.from_now
    j.status = 'pending'
    j.priority = 'high'
    j.comment = 'Urgente - documentação necessária'
    j.team = team
    j.created_by_id = user1.id
    puts "  [OK] Created job with customer: #{j.description}"
  end
end

# Associate user profile with job
JobUserProfile.find_or_create_by!(job: job1, user_profile: profile1, role: 'assignee')

if work2
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
    puts "  [OK] Created job with work: #{j.description}"
  end
else
  # Create job associated only with customer
  # Keep using team1 since the customer is associated with team1
  job2 = Job.find_or_create_by!(
    description: 'Coletar documentos do cliente',
    profile_customer: profile_customer2
  ) do |j|
    j.deadline = 3.days.from_now
    j.status = 'pending'
    j.priority = 'medium'
    j.team = team
    j.created_by_id = user1.id  # Use user1 who belongs to team1
    puts "  [OK] Created job with customer: #{j.description}"
  end
end

# Associate user profile with job - use profile1 which belongs to team1
JobUserProfile.find_or_create_by!(job: job2, user_profile: profile1, role: 'assignee')

# Create a job without work association
job3 = Job.find_or_create_by!(
  description: 'Revisar contratos pendentes',
  profile_customer: profile_customer2
) do |j|
  j.deadline = 5.days.from_now
  j.status = 'pending'
  j.priority = 'low'
  j.comment = 'Revisão geral de contratos'
  j.team = team
  j.created_by_id = user1.id
  puts "  [OK] Created job with customer: #{j.description}"
end

JobUserProfile.find_or_create_by!(job: job3, user_profile: profile1, role: 'assignee')

puts "  [OK] Jobs created successfully!"