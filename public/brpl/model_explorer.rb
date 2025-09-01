#!/usr/bin/env ruby
# frozen_string_literal: true

# model_explorer.rb
# Usage: rails runner public/model_explorer.rb Work
# Fazer todos os modelos
# Adicionar quando modelos forem alterados -> Deletar antigos

class ModelExplorer
  def self.generate_markdown(model_class)
    model_name = model_class.name

    # Create markdown file
    docs_dir = Rails.root.join('docs/models')
    FileUtils.mkdir_p(docs_dir) unless docs_dir.exist?
    file_path = docs_dir.join("#{model_name.underscore}_info.md")
    File.open(file_path, 'w') do |file|
      file.puts "# #{model_name} Model Information\n\n"

      # Attributes and their types
      file.puts "## Attributes\n\n"
      file.puts '```ruby'
      file.puts "#{model_name}.new"
      file.puts ''

      # Get required fields from validations
      required_fields = Set.new
      model_class.validators.each do |validator|
        if validator.is_a?(ActiveModel::Validations::PresenceValidator) && validator.respond_to?(:attributes)
          required_fields.merge(validator.attributes.map(&:to_s))
        end
      end

      model_class.columns_hash.each do |name, column|
        annotations = []
        annotations << column.type.to_s
        annotations << 'required*' if required_fields.include?(name) || !column.null
        annotation_str = annotations.join(' # ')
        file.puts "#{name}, # #{annotation_str}"
      end

      file.puts "```\n\n"

      # Associations
      file.puts "## Associations\n\n"

      [:has_many, :has_one, :belongs_to, :has_and_belongs_to_many].each do |assoc_type|
        associations = model_class.reflect_on_all_associations(assoc_type)

        next if associations.empty?

        file.puts "### #{assoc_type.to_s.titleize}\n\n"
        file.puts '```ruby'

        associations.each do |association|
          options = association.options.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')
          file.puts "#{assoc_type} :#{association.name}#{", #{options}" if options.present?}"
        end

        file.puts "```\n\n"
      end

      # Validations
      file.puts "## Validations\n\n"
      file.puts '```ruby'

      model_class.validators.each do |validator|
        # Check if validator has attributes method (standard validators do)
        if validator.respond_to?(:attributes)
          attributes = validator.attributes.map(&:to_s).join(', ')
          options = validator.options.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')
          validator_type = validator.class.name.demodulize.underscore.gsub('_validator', '')
          file.puts "validates :#{attributes}, #{validator_type}: #{options.presence || 'true'}"
        else
          # Custom validators without attributes
          validator_name = validator.class.name.demodulize
          file.puts "validates_with #{validator_name}"
        end
      end

      file.puts "```\n\n"

      # Scopes
      begin
        file.puts "## Scopes\n\n"
        file.puts '```ruby'

        # Get all scopes defined on the model
        if model_class.respond_to?(:scopes)
          model_class.scopes.each_key do |scope_name|
            file.puts "scope :#{scope_name}"
          end
        end

        file.puts "```\n\n"
      rescue StandardError => e
        file.puts "Error getting scopes: #{e.message}\n\n"
      end

      # Add callbacks information (if available)
      begin
        file.puts "## Callbacks\n\n"
        file.puts '```ruby'

        if model_class.respond_to?(:_callbacks)
          [:before_validation, :after_validation, :before_save, :after_save,
           :before_create, :after_create, :before_update, :after_update,
           :before_destroy, :after_destroy].each do |callback_type|
            callbacks = model_class._callbacks[callback_type]
            next unless callbacks&.any?

            callbacks.each do |callback|
              if callback.filter && !callback.filter.to_s.start_with?('_')
                file.puts "#{callback_type} :#{callback.filter}"
              end
            end
          end
        else
          file.puts '# Callbacks information not available'
        end

        file.puts "```\n\n"
      rescue StandardError => e
        file.puts "# Error getting callbacks: #{e.message}\n\n"
      end
    end

    puts "Generated model information at #{file_path}"
  end
end

# Main execution
if ARGV.empty?
  puts 'Usage: rails runner public/model_explorer.rb ModelName'
  puts 'Example: rails runner public/model_explorer.rb Work'
  exit 1
end

begin
  # Try to constantize the model name
  model_name = ARGV[0]

  # First try direct constantize
  model_class = begin
    model_name.constantize
  rescue StandardError
    nil
  end

  # If that doesn't work, try with ::
  model_class ||= begin
    "::#{model_name}".constantize
  rescue StandardError
    nil
  end

  # If still nothing, try loading the model file directly
  if model_class.nil?
    # Try to require the model file
    possible_paths = [
      "app/models/#{model_name.underscore}.rb",
      "app/models/#{model_name.underscore.pluralize}.rb"
    ]

    possible_paths.each do |path|
      next unless Rails.root.join(path).exist?

      require Rails.root.join(path)
      model_class = begin
        model_name.constantize
      rescue StandardError
        nil
      end
      break if model_class
    end
  end

  if model_class.nil?
    puts "Error: Model '#{model_name}' not found"
    puts "\nAvailable models:"

    # List all available models
    Rails.application.eager_load!
    ApplicationRecord.descendants.sort_by(&:name).each do |model|
      puts "  - #{model.name}"
    end
    exit 1
  end

  ModelExplorer.generate_markdown(model_class)
rescue StandardError => e
  puts "Error: #{e.message}"
  puts e.backtrace.first(5)
  exit 1
end
