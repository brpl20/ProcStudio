# Guia de Instalação e Execução do Projeto

Este documento descreve os passos necessários para configurar e executar o ambiente de desenvolvimento localmente.

## 🚀 Pré-requisitos

Antes de começar, garanta que você tenha os seguintes softwares instalados em sua máquina:

*   **PostgreSQL (Versão 14)**: Sistema de gerenciamento de banco de dados.
    *   Você pode baixar através do instalador oficial: "https://www.postgresql.org/download/" windows" PostgreSQL para Windows.
    *   Durante a instalação, o **pgAdmin** também será instalado, o que usaremos para gerenciar as bases de dados.

*   **Ruby + DevKit (x64)**: Linguagem de programação do backend.
    *   Recomendamos usar o "https://rubyinstaller.org/downloads/" RubyInstaller para Windows, que já inclui o DevKit.

*   **Memurai (Developer Edition)**: Um cache de dados na memória compatível com a API do Redis, usado pelo projeto.
    *   Pode ser instalado via `winget` em um terminal com privilégios de administrador:
      ```bash
      winget install -e --id Memurai.MemuraiDeveloper
      ```

*   **Node.js**: Gerenciador de pacotes e ambiente de execução para o frontend.
    *   Baixe o Node.js "https://nodejs.org/" aqui (que inclui o `npm`).

## ⚙️ Configuração do Ambiente

Siga estes passos para configurar o projeto após clonar o repositório.

### 1. Configurando o Backend (API)

Navegue até a pasta da API e instale as dependências do Ruby.

```bash
# Navegue até o diretório da API
cd sua-pasta-api/

# Instale o Bundler, que gerencia as dependências (gems) do projeto
gem install bundler

# Instale todas as gems listadas no Gemfile
bundle install
```

### 2. Configurando o Frontend

Navegue até a pasta do frontend e instale as dependências JavaScript.

```bash
# Navegue até o diretório do frontend
cd sua-pasta-front/

# Instale todas as dependências listadas no package.json
npm install
```

### 3. Configurando o Banco de Dados (PostgreSQL)

Esta etapa envolve a criação das bases de dados e a configuração das credenciais de acesso.

1.  **Abra o pgAdmin**.
2.  **Crie um usuário** e uma **senha** para o projeto. **Anote bem essa senha**, pois ela será usada nos arquivos de configuração. Para este guia, vamos assumir que o nome de usuário é `postgres`.
3.  **Crie as bases de dados** necessárias para o ambiente de desenvolvimento e teste.
    *   `prc_api_development`
    *   `prc_api_test`
    > **Dica**: No pgAdmin, você pode clicar com o botão direito em "Databases" -> "Create" -> "Database".

### 4. Arquivos de Configuração

Agora, vamos informar à aplicação como se conectar ao banco de dados.

1.  Na pasta da API, renomeie o arquivo `database.yml.example` para `database.yml`.
2.  Abra o arquivo `database.yml` e edite as seções `development` e `test` com o usuário e a senha que você configurou no pgAdmin:
    ```yaml
    development:
      adapter: postgresql
      encoding: unicode
      database: prc_api_development
      pool: 5
      username: postgres # Usuário que você criou
      password: SUA_SENHA_AQUI # Senha que você anotou
    ```
3.  Verifique também o arquivo `application.yml` (ou `application.yml.example`) e atualize as credenciais do banco de dados (`DB_USERNAME`, `DB_PASSWORD`) se elas estiverem sendo usadas lá.

### 5. Preparando o Banco de Dados

Com a aplicação configurada, vamos criar as tabelas e popular os dados iniciais.

```bash
# Garanta que você está na pasta da API
cd sua-pasta-api/

# Executa as migrações para criar a estrutura do banco de dados
rails db:migrate

# Popula o banco de dados com os dados iniciais (seeds)
rails db:seed
```

## 🟢 Executando a Aplicação

Para rodar a aplicação completa, você precisará de **três terminais abertos** simultaneamente.

### Terminal 1: Iniciar o Cache (Memurai)
Abra um terminal (PowerShell ou CMD) e inicie o serviço do Memurai.

```bash
memurai
```

### Terminal 2: Iniciar o Backend (API)
Abra um segundo terminal, navegue até a pasta da API e inicie o servidor Rails.

```bash
# Navegue até a pasta da API
cd sua-pasta-api/

# Inicie o servidor
rails server
```

### Terminal 3: Iniciar o Frontend
Abra um terceiro terminal, navegue até a pasta do frontend e inicie o servidor de desenvolvimento.

```bash
# Navegue até a pasta do frontend
cd sua-pasta-front/

# Inicie o servidor de desenvolvimento
npm run dev
```

Pronto!