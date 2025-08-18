# frozen_string_literal: true

namespace :staging do
  desc 'Setup Development'
  task setup: :environment do
    p 'Running setup for development/staging...'

    p "Dropping database... #{`rails db:drop`}"
    p "Creating database... #{`rails db:create`}"
    p "Migrating tables...  #{`rails db:migrate`}"

    p "Creating office_type #{`rake cad:office_type`}"

    p 'Creating office'
    p `rake cad:office`

    p 'Creating admins'
    p `rake cad:admin`

    p 'Loading seeds Offices + AdminUsers'
    p `rake db:seed`

    p 'Creating customer'
    p `rake cad:customer`

    p 'Creating powers'
    p `rake cad:power`

    p 'Setup completed successfully!'
  end
end
