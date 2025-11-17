# Test script for S3 implementation
# Run this in Rails console: rails runner test_s3_implementation.rb

require 'open-uri'
require 'tempfile'

puts "=" * 60
puts "S3 Implementation Test Script"
puts "=" * 60

# Helper method to create a test file
def create_test_file(filename, content = nil)
  file = Tempfile.new([filename.split('.').first, ".#{filename.split('.').last}"])
  file.write(content || "Test content for #{filename} - #{Time.current}")
  file.rewind

  # Create an uploaded file object
  content_type = case filename.split('.').last.downcase
                 when 'png' then 'image/png'
                 when 'jpg', 'jpeg' then 'image/jpeg'
                 when 'pdf' then 'application/pdf'
                 when 'docx' then 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
                 else 'application/octet-stream'
                 end

  ActionDispatch::Http::UploadedFile.new(
    tempfile: file,
    filename: filename,
    type: content_type
  )
end

# Test setup
team = Team.first
if team.nil?
  puts "❌ No teams found. Please create a team first."
  exit 1
end

user = User.joins(:user_profile).where.not(user_profiles: { id: nil }).first
if user.nil?
  puts "❌ No users with profiles found. Please create a user with profile first."
  exit 1
end

user_profile = user.user_profile
office = Office.first || Office.create!(
  name: "Test Office #{SecureRandom.hex(4)}",
  team: team,
  society: 'individual',
  cnpj: '11.222.333/0001-81'
)

puts "\n📋 Test Environment:"
puts "  Team: #{team.name} (ID: #{team.id})"
puts "  User: #{user.email}"
puts "  UserProfile: #{user_profile.full_name} (ID: #{user_profile.id})"
puts "  Office: #{office.name} (ID: #{office.id})"

# Test 1: Office Logo Upload
puts "\n" + "=" * 40
puts "Test 1: Office Logo Upload"
puts "=" * 40

begin
  logo_file = create_test_file('test_logo.png')
  logo_metadata = office.upload_logo(logo_file, user_profile: user_profile, description: "Test logo upload")

  if logo_metadata && office.logo_url
    puts "✅ Logo uploaded successfully!"
    puts "   S3 Key: #{logo_metadata.s3_key}"
    puts "   URL: #{office.logo_url}"
    puts "   File size: #{logo_metadata.byte_size} bytes"
    puts "   Checksum: #{logo_metadata.checksum}"
  else
    puts "❌ Logo upload failed"
  end
rescue => e
  puts "❌ Error uploading logo: #{e.message}"
  puts e.backtrace.first(5)
end

# Test 2: Office Social Contract Upload
puts "\n" + "=" * 40
puts "Test 2: Office Social Contract Upload"
puts "=" * 40

begin
  contract_file = create_test_file('social_contract.pdf')
  contract_metadata = office.upload_social_contract(
    contract_file,
    user_profile: user_profile,
    system_generated: false,
    version: "1.0"
  )

  if contract_metadata
    puts "✅ Social contract uploaded successfully!"
    puts "   S3 Key: #{contract_metadata.s3_key}"
    puts "   URLs count: #{office.social_contract_urls.count}"
    puts "   System generated: #{contract_metadata.system_generated?}"
  else
    puts "❌ Social contract upload failed"
  end
rescue => e
  puts "❌ Error uploading social contract: #{e.message}"
  puts e.backtrace.first(5)
end

# Test 3: UserProfile Avatar Upload
puts "\n" + "=" * 40
puts "Test 3: UserProfile Avatar Upload"
puts "=" * 40

begin
  avatar_file = create_test_file('avatar.jpg')
  avatar_metadata = user_profile.upload_avatar(avatar_file)

  if avatar_metadata && user_profile.avatar_url
    puts "✅ Avatar uploaded successfully!"
    puts "   S3 Key: #{avatar_metadata.s3_key}"
    puts "   URL: #{user_profile.avatar_url}"
    puts "   Uploaded by: #{avatar_metadata.uploaded_by&.full_name}"
  else
    puts "❌ Avatar upload failed"
  end
rescue => e
  puts "❌ Error uploading avatar: #{e.message}"
  puts e.backtrace.first(5)
end

# Test 4: Job Attachment Upload
puts "\n" + "=" * 40
puts "Test 4: Job Attachment Upload"
puts "=" * 40

begin
  job = Job.first || Job.create!(
    title: "Test Job #{SecureRandom.hex(4)}",
    description: "Test job for S3 implementation",
    deadline: 7.days.from_now,
    team: team,
    created_by: user,
    status: 'pending',
    priority: 'medium'
  )

  attachment_file = create_test_file('job_attachment.docx')
  attachment_metadata = job.upload_attachment(attachment_file, user_profile: user_profile)

  if attachment_metadata
    puts "✅ Job attachment uploaded successfully!"
    puts "   Job: #{job.title} (ID: #{job.id})"
    puts "   S3 Key: #{attachment_metadata.s3_key}"
    puts "   Attachment URLs count: #{job.attachment_urls.count}"
  else
    puts "❌ Job attachment upload failed"
  end
rescue => e
  puts "❌ Error uploading job attachment: #{e.message}"
  puts e.backtrace.first(5)
end

# Test 5: Work Document Upload
puts "\n" + "=" * 40
puts "Test 5: Work Document Upload"
puts "=" * 40

begin
  law_area = LawArea.first || LawArea.create!(
    name: "Test Law Area",
    code: "TEST",
    area_type: 'main'
  )

  work = Work.first || Work.create!(
    team: team,
    law_area: law_area,
    work_status: 'active'
  )

  # Test procuration document
  procuration_file = create_test_file('procuration.pdf')
  proc_metadata = work.upload_document(
    procuration_file,
    document_type: 'procuration',
    user_profile: user_profile
  )

  if proc_metadata
    puts "✅ Work procuration uploaded successfully!"
    puts "   Work ID: #{work.id}"
    puts "   S3 Key: #{proc_metadata.s3_key}"
    puts "   Document type: procuration"
    puts "   Total documents: #{work.work_documents.count}"
  else
    puts "❌ Work document upload failed"
  end
rescue => e
  puts "❌ Error uploading work document: #{e.message}"
  puts e.backtrace.first(5)
end

# Test 6: Temporary Upload
puts "\n" + "=" * 40
puts "Test 6: Temporary Upload"
puts "=" * 40

begin
  temp_file = create_test_file('temporary_document.pdf')
  temp_upload = TempUpload.create_from_file(
    temp_file,
    user_profile: user_profile,
    team: team
  )

  if temp_upload && temp_upload.file_metadata
    puts "✅ Temporary file uploaded successfully!"
    puts "   TempUpload ID: #{temp_upload.id}"
    puts "   S3 Key: #{temp_upload.file_metadata.s3_key}"
    puts "   Expires at: #{temp_upload.expires_at}"
    puts "   Original filename: #{temp_upload.original_filename}"
  else
    puts "❌ Temporary upload failed"
  end
rescue => e
  puts "❌ Error creating temporary upload: #{e.message}"
  puts e.backtrace.first(5)
end

# Test 7: List Files by Team
puts "\n" + "=" * 40
puts "Test 7: List Files by Team"
puts "=" * 40

begin
  team_files = S3Manager.list(team.id)

  puts "📁 Files for Team #{team.name}:"
  puts "   Total files: #{team_files.count}"

  by_category = team_files.group_by(&:file_category)
  by_category.each do |category, files|
    puts "   #{category || 'uncategorized'}: #{files.count} files"
  end

  system_files = team_files.select(&:system_generated?)
  user_files = team_files.select(&:user_uploaded?)

  puts "\n📊 File Statistics:"
  puts "   System generated: #{system_files.count}"
  puts "   User uploaded: #{user_files.count}"
  puts "   Temporary files: #{team_files.select(&:temporary?).count}"
  puts "   Permanent files: #{team_files.select { |f| !f.temporary? }.count}"

rescue => e
  puts "❌ Error listing team files: #{e.message}"
  puts e.backtrace.first(5)
end

# Summary
puts "\n" + "=" * 60
puts "Test Summary"
puts "=" * 60

total_files = FileMetadata.count
puts "✅ Total FileMetadata records created: #{total_files}"
puts "✅ Total TempUpload records: #{TempUpload.count}"

# Check for any expired files
expired = FileMetadata.expired.count
if expired > 0
  puts "⚠️  Found #{expired} expired files (will be cleaned up by background job)"
end

puts "\n🎉 S3 Implementation Test Complete!"
puts "=" * 60