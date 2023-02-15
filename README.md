Skeleton rails 7

## Informações do projeto
Este projeto contém autenticação com Devise e um exemplo de tabela na página home utilizando Datatables.

## Pré requisitos

 > Ruby 3.0.0

 > Rails 7.0.4.2

## Instalação

 - Faça um clone do Projeto
 - Configure o arquivo do banco de dados
   ```config/database.yml```
 - Execute em sequência no terminal os comandos:
  ``` 
      bundle
      rake db:create db:migrate
      rails s
  ```

  Então acesse via navegador:
  ``` 
      http://localhost:3000
  ```

Caso não venha a utilizar a tela Home, você pode apagá-la executando no terminal:
  ```
      rails d controller home
  ```
