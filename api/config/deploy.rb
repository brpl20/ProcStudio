# frozen_string_literal: true

require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'

# set :rvm_path, '/usr/james/.rvm/scripts/rvm'
# set :ruby_version, '3.0.0'

task :remote_environment do
  invoke :'rvm:use[ruby-3.0.0]'
end

task setup: :remote_environment do
  queue! %(mkdir -p "#{deploy_to}/shared/log")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/log")

  queue! %(mkdir -p "#{deploy_to}/storage")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/storage")

  queue! %(touch "#{deploy_to}/storage/index.html")

  queue! %(mkdir -p "#{deploy_to}/shared/config")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/config")

  queue! %(mkdir -p "#{deploy_to}/shared/pids")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/pids")

  queue! %(mkdir -p "#{deploy_to}/shared/tmp")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/tmp")

  queue! %(touch "#{deploy_to}/shared/config/database.yml")
  queue  %(echo "-----> Be sure to edit 'shared/config/database.yml'.")

  queue! %(touch "#{deploy_to}/shared/config/application.yml")
  queue  %(echo "-----> Be sure to edit 'shared/config/application.yml'.")

  queue! %(touch "#{deploy_to}/shared/config/secrets.yml")
  queue  %(echo "-----> Be sure to edit 'shared/config/secrets.yml'.")
end

desc 'Deploys the current version to the server.'
task deploy: :remote_environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'deploy:cleanup'

    to :launch do
      queue %(echo -n '-----> Creating new restart.txt: ')
      queue "touch #{deploy_to}/shared/tmp/restart.txt"
    end
  end
end

set :repository, 'git@github.com:SoftOwn-Solutions/SoftOwn_procstudio_api.git'
set :domain, '168.231.90.14'
set :branch, 'main'
set :forward_agent, true

# Server Production
task :production do
  set :rails_env, 'production'
  set :user, 'procstudio_prd'
  set :deploy_to, '/home/procstudio_prd/SoftOwn_procstudio_api'
end

# Server staging
task :staging do
  set :rails_env, 'staging'
  set :user, 'procstudio_hml'
  set :deploy_to, '/home/procstudio_hml/SoftOwn_procstudio_api'
end

# Fix
set :term_mode, nil

set :shared_paths,
    ['public/uploads', 'config/database.yml', 'log', 'tmp', 'config/application.yml', 'config/secrets.yml']

# Show logs
desc 'Show logs rails.'
task 'logs:rails': :remote_environment do
  queue 'echo "Contents of the log file are as follows:"'
  queue "tail -f #{deploy_to}/shared/log/production.log"
end

desc 'Show logs Nginx.'
task 'logs:nginx': :remote_environment do
  queue 'echo "Contents of the log file are as follows:"'
  queue 'tail -f /opt/nginx/logs/error.log'
end

# Roolback
desc 'Rolls back the latest release'
task rollback: :remote_environment do
  queue! %(echo "-----> Rolling back to previous release for instance: #{domain}")

  # Delete existing sym link and create a new symlink pointing to the previous release
  queue %(echo -n "-----> Creating new symlink from the previous release: ")
  queue %(ls "#{deploy_to}/releases" -Art | sort | tail -n 2 | head -n 1)
  queue! %(ls -Art "#{deploy_to}/releases" | sort | tail -n 2 | head -n 1 | ) +
         %(xargs -I active ln -nfs "#{deploy_to}/releases/active" "#{deploy_to}/current")

  # Remove latest release folder (active release)
  queue %(echo -n "-----> Deleting active release: ")
  queue %(ls "#{deploy_to}/releases" -Art | sort | tail -n 1)
  queue! %(ls "#{deploy_to}/releases" -Art | sort | tail -n 1 | xargs -I active rm -rf "#{deploy_to}/releases/active")

  queue %(echo -n "-----> Creating new restart.txt: ")
  queue "touch #{deploy_to}/shared/tmp/restart.txt"
end

# Maintenance
# TornOff (Necessary gem https://github.com/biola/turnout)
desc 'TurnOff'
task 'system:turnoff': :remote_environment do
  queue %(echo -n "-----> Turn Off System: ")
  queue! %(cd "#{deploy_to}/current")
  queue "RAILS_ENV=#{rails_env} bundle exec rake maintenance:start"
end

desc 'TurnOn'
task 'system:turnon': :remote_environment do
  queue %(echo -n "-----> Turn Off System: ")
  queue! %(cd "#{deploy_to}/current")
  queue "RAILS_ENV=#{rails_env} bundle exec rake maintenance:end"
end
