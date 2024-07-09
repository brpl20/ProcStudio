namespace :staging do

  desc 'Setup Development'
  task setup: :environment do

    p 'Running setup for development/staging...'

    p "Dropping database... #{%x(rails db:drop)}"
    p "Creating database... #{%x(rails db:create)}"
    p "Migrating tables...  #{%x(rails db:migrate)}"

    p "Creating office_type #{%x(rake cad:office_type)}"

    p 'Creating office'
    p %x(rake cad:office)

    p 'Creating admins'
    p %x(rake cad:admin)

    p 'Loading seeds Offices + AdminUsers'
    p %x(rake db:seed)

    p 'Creating customer'
    p %x(rake cad:customer)

    p 'Creating powers'
    p %x(rake cad:power)

    p 'Setup completed successfully!'

  end
end
