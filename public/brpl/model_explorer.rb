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

      # Related Files Section
      file.puts "## Related Files\n\n"
      related_files = find_related_files(model_name)

      if related_files.any?
        related_files.each do |category, files|
          next if files.empty?

          file.puts "### #{category}\n"
          files.each do |file_path|
            file.puts "- `#{file_path}`"
          end
          file.puts ''
        end
      else
        file.puts "_No related files found_\n"
      end
      file.puts ''

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

      # Add instance methods with usage examples
      file.puts "## Key Methods & Usage Examples\n\n"
      generate_method_examples(model_class, file)

      # Add serializer information
      file.puts "## Serializer\n\n"
      generate_serializer_info(model_class, file)
    end

    puts "Generated model information at #{file_path}"
  end

  def self.find_related_files(model_name)
    related_files = {
      'Model' => [],
      'Controllers' => [],
      'Serializers' => [],
      'Services' => [],
      'Jobs' => [],
      'Filters' => []
    }

    # Model file
    model_path = "app/models/#{model_name.underscore}.rb"
    related_files['Model'] << model_path if Rails.root.join(model_path).exist?

    # Controllers
    controller_patterns = [
      "app/controllers/**/*#{model_name.underscore.pluralize}_controller.rb",
      "app/controllers/**/*#{model_name.underscore}_controller.rb"
    ]

    controller_patterns.each do |pattern|
      Rails.root.glob(pattern).each do |path|
        relative_path = path.to_s.gsub(Rails.root.join.to_s, '')
        related_files['Controllers'] << relative_path
      end
    end

    # Serializers
    serializer_patterns = [
      "app/serializers/#{model_name.underscore}_serializer.rb",
      "app/serializers/**/#{model_name.underscore}_serializer.rb"
    ]

    serializer_patterns.each do |pattern|
      Rails.root.glob(pattern).each do |path|
        relative_path = path.to_s.gsub(Rails.root.join.to_s, '')
        related_files['Serializers'] << relative_path
      end
    end

    # Services
    service_patterns = [
      "app/models/services/#{model_name.underscore.pluralize}.rb",
      "app/services/*#{model_name.underscore}*.rb"
    ]

    service_patterns.each do |pattern|
      Rails.root.glob(pattern).each do |path|
        relative_path = path.to_s.gsub(Rails.root.join.to_s, '')
        related_files['Services'] << relative_path
      end
    end

    # Jobs
    job_patterns = [
      "app/jobs/*#{model_name.underscore}*.rb"
    ]

    job_patterns.each do |pattern|
      Rails.root.glob(pattern).each do |path|
        relative_path = path.to_s.gsub(Rails.root.join.to_s, '')
        related_files['Jobs'] << relative_path
      end
    end

    # Filters
    filter_patterns = [
      "app/models/filters/#{model_name.underscore}_filter.rb"
    ]

    filter_patterns.each do |pattern|
      Rails.root.glob(pattern).each do |path|
        relative_path = path.to_s.gsub(Rails.root.join.to_s, '')
        related_files['Filters'] << relative_path
      end
    end

    related_files
  end

  def self.generate_method_examples(model_class, file)
    # Get an instance for demonstration
    instance_example = "#{model_class.name.underscore} = #{model_class.name}.new"

    file.puts "### Instance Creation\n"
    file.puts '```ruby'
    file.puts instance_example
    file.puts "# Returns: #<#{model_class.name} ...>"
    file.puts "```\n\n"

    # Common finder methods
    file.puts "### Finder Methods\n"
    file.puts '```ruby'
    file.puts '# Find by ID'
    file.puts "#{model_class.name}.find(1)"
    file.puts "# Returns: #<#{model_class.name} id: 1, ...> or raises ActiveRecord::RecordNotFound"
    file.puts ''
    file.puts '# Find by attributes'
    if model_class.column_names.include?('name')
      file.puts "#{model_class.name}.find_by(name: 'Example')"
      file.puts "# Returns: #<#{model_class.name} ...> or nil"
    elsif model_class.column_names.include?('email')
      file.puts "#{model_class.name}.find_by(email: 'user@example.com')"
      file.puts "# Returns: #<#{model_class.name} ...> or nil"
    else
      first_col = model_class.column_names.reject { |c| ['id', 'created_at', 'updated_at'].include?(c) }.first
      if first_col
        file.puts "#{model_class.name}.find_by(#{first_col}: 'value')"
        file.puts "# Returns: #<#{model_class.name} ...> or nil"
      end
    end
    file.puts ''
    file.puts '# Where clause'
    file.puts "#{model_class.name}.where(active: true)"
    file.puts '# Returns: ActiveRecord::Relation'
    file.puts "```\n\n"

    # Custom instance methods
    custom_methods = model_class.instance_methods(false).reject { |m| m.to_s.end_with?('=') || m.to_s.start_with?('_') }

    if custom_methods.any?
      file.puts "### Custom Instance Methods\n"
      file.puts '```ruby'
      custom_methods.first(5).each do |method_name|
        arity = model_class.instance_method(method_name).arity
        params = if arity.zero?
                   ''
                 elsif arity.positive?
                   "(#{Array.new(arity) { |i| "arg#{i + 1}" }.join(', ')})"
                 else
                   '(...)'
                 end
        file.puts "#{model_class.name.underscore}.#{method_name}#{params}"
        file.puts '# Implement: Check method definition for return value'
      end
      file.puts "```\n\n"
    end

    # Class methods
    class_methods = model_class.methods(false).reject { |m| m.to_s.end_with?('=') || m.to_s.start_with?('_') }

    if class_methods.any?
      file.puts "### Custom Class Methods\n"
      file.puts '```ruby'
      class_methods.first(5).each do |method_name|
        file.puts "#{model_class.name}.#{method_name}"
        file.puts '# Implement: Check method definition for return value'
      end
      file.puts "```\n\n"
    end
  rescue StandardError => e
    file.puts "_Error generating method examples: #{e.message}_\n\n"
  end

  def self.generate_serializer_info(model_class, file)
    begin
      serializer_name = "#{model_class.name}Serializer"
      serializer_path = "app/serializers/#{model_class.name.underscore}_serializer.rb"

      # Check if serializer exists
      if Rails.root.join(serializer_path).exist?
        file.puts "### Serializer Class\n"
        file.puts "- **Class**: `#{serializer_name}`"
        file.puts "- **File**: `#{serializer_path}`\n\n"

        # Try to load and analyze the serializer
        begin
          require Rails.root.join(serializer_path)
          serializer_class = serializer_name.constantize

          # Generate example response
          file.puts "### Example Serialized Response\n"
          file.puts '```json'

          # Create a sample instance for demonstration
          sample_data = {}
          model_class.columns_hash.each do |name, column|
            sample_data[name.to_sym] = case column.type
                                       when :string, :text
                                         "example_#{name}"
                                       when :integer
                                         name == 'id' ? 1 : 100
                                       when :boolean
                                         true
                                       when :datetime
                                         '2024-01-01T12:00:00Z'
                                       when :decimal, :float
                                         99.99
                                       when :json, :jsonb
                                         {}
                                       else
                                         'value'
                                       end
          end

          # Show sample JSON structure
          file.puts '{'

          # Get serializer attributes if possible
          if serializer_class.respond_to?(:_attributes)
            serializer_class._attributes.each do |attr|
              value = sample_data[attr] || "example_#{attr}"
              file.puts "  \"#{attr}\": #{value.to_json},"
            end
          else
            # Fallback to model attributes
            sample_data.each do |key, value|
              file.puts "  \"#{key}\": #{value.to_json},"
            end
          end

          # Add associations if any
          [:has_many, :has_one, :belongs_to].each do |assoc_type|
            associations = model_class.reflect_on_all_associations(assoc_type)
            associations.each do |association|
              case assoc_type
              when :has_many
                file.puts "  \"#{association.name}\": [],"
              when :has_one, :belongs_to
                file.puts "  \"#{association.name}\": null,"
              end
            end
          end

          file.puts '}'
          file.puts '```'
        rescue StandardError => e
          file.puts "_Could not load serializer: #{e.message}_"
        end
      else
        file.puts '_No serializer found for this model_'
        file.puts "\nTo create one:"
        file.puts '```bash'
        file.puts "rails generate serializer #{model_class.name}"
        file.puts '```'
      end
    rescue StandardError => e
      file.puts "_Error generating serializer info: #{e.message}_"
    end

    file.puts "\n"
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
