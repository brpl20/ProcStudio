if defined?(Rails)
  extend Rails::ConsoleMethods if Rails.application
end

# Load Rails environment if running from Rails root
if File.exist?('./config/environment.rb')
  require './config/environment'
end