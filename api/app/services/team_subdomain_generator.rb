# frozen_string_literal: true

class TeamSubdomainGenerator
  def self.generate(name: nil, email: nil)
    new(name: name, email: email).generate
  end

  def initialize(name: nil, email: nil)
    @name = name
    @email = email
  end

  def generate
    base_subdomain = generate_base_subdomain
    ensure_unique_subdomain(base_subdomain)
  end

  private

  attr_reader :name, :email

  def generate_base_subdomain
    # Prioridade: nome do advogado > email (parte antes do @)
    if name.present?
      normalize_string(name)
    elsif email.present?
      email_prefix = email.split('@').first
      normalize_string(email_prefix)
    else
      'escritorio'
    end
  end

  def normalize_string(str)
    str.to_s
      .unicode_normalize(:nfkd) # Remove acentos
      .gsub(/[^\x00-\x7F]/, '')                   # Remove caracteres não-ASCII
      .downcase                                   # Minúsculas
      .gsub(/[^a-z0-9\s]/, '') # Só letras, números e espaços
      .strip # Remove espaços das bordas
      .gsub(/\s+/, '-').squeeze('-') # Remove hífens duplicados
      .gsub(/^-|-$/, '') # Remove hífens das bordas
      .presence || 'escritorio' # Fallback se ficar vazio
  end

  def ensure_unique_subdomain(base_subdomain)
    return base_subdomain unless Team.exists?(subdomain: base_subdomain)

    # Se já existe, adiciona número até encontrar um único
    counter = 1
    loop do
      candidate = "#{base_subdomain}#{counter}"
      return candidate unless Team.exists?(subdomain: candidate)

      counter += 1
      # Segurança para não fazer loop infinito
      break if counter > 9999
    end

    # Fallback com timestamp se chegou no limite
    "#{base_subdomain}#{Time.current.to_i}"
  end
end
