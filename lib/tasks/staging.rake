namespace :staging do
  desc 'Setup Development'
  task setup: :environment do
    admin_only = ENV['ADMIN_ONLY'] == 'true'

    p 'Running setup for development/staging...'

    p "Dropping database... #{%x(rails db:drop)}"
    p "Creating database... #{%x(rails db:create)}"
    p "Migrating tables...  #{%x(rails db:migrate)}"
    p "Creating office_type #{%x(rake cad:office_type)}"

    if admin_only
      p 'Creating admin only'
      p %x(rake cad:admin ADMIN_ONLY=true)
    else
      p 'Creating admin and profile'
      p %x(rake cad:admin)

      p 'Creating office and linking to admin'
      p %x(rake cad:office_with_admin)
    end

    p 'Creating powers'
    p %x(rake cad:power)

    p 'Setup completed successfully!'
  end
end
