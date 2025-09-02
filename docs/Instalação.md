[Back](../README.md)

## Início Rápido

### Requisitos
- Ruby 3.2.7
- Rails 8.0.2.1
- PostgreSQL
- Redis (para cache e jobs)

### Configuração

#### 1. Instalar Ruby e dependências
```bash
# Instalar Ruby 3.2.7 (se usando rbenv)
rbenv install 3.2.7
rbenv global 3.2.7

# Instalar bundler
gem install bundler

# Instalar dependências do projeto
bundle install
```

#### 2. Configurar PostgreSQL
```bash
# No Ubuntu/Debian
sudo apt-get install postgresql postgresql-contrib

# No macOS com Homebrew
brew install postgresql

# Criar usuário postgres com senha
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'password';"

# Criar bancos de desenvolvimento e teste
sudo -u postgres createdb prc_api_development
sudo -u postgres createdb prc_api_test
```

#### 3. Configurar banco de dados
```bash
# Copiar arquivo de configuração de exemplo
cp config/database.yml.example config/database.yml

# Editar config/database.yml com suas credenciais PostgreSQL
# As configurações padrão usam:
# - usuário: postgres
# - senha: password
# - host: localhost
# - porta: 5432

# Executar migrações
rails db:migrate

# Popular banco com dados iniciais (opcional)
rails db:seed
```

#### 4. Configurar variáveis de ambiente
Para API keys e senhas diversas busque no BitWarden por segurança.

```bash
# Copiar arquivo de exemplo
cp .env.example .env

# Editar .env com suas configurações
```

#### 5. Iniciar aplicação
```bash
# Iniciar servidor de desenvolvimento
rails server

# A API estará disponível em http://localhost:3000

# Executar testes (opcional)
rspec
```
