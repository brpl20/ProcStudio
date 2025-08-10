namespace :staging do
  desc 'Setup Development'
  task setup_simple: :environment do

    p 'Running setup for development/staging...'
    p "Dropping database... #{%x(rails db:drop)}"
    p "Creating database... #{%x(rails db:create)}"
    p "Migrating tables...  #{%x(rails db:migrate)}"
    p "Creating office_type #{%x(rake cad:office_type)}"
    p "Creating powers      #{%x(rake cad:power)}"
    p 'Setup completed successfully!'
  end
end
