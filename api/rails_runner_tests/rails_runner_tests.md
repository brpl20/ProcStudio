# Rails Runner Tests

Esse diretório é apenas para testes relacionados com o Rails Runner, usando o Rails Runner, para testes em geral vá até `../tests`.

Rails Runner são comandos que executam código Ruby dentro do contexto completo do sistema Rails sem você precisar usar o console, o browser ou qualquer outra coisa, isso ajuda a criar testes simples independentes do RSpec.

O detalhe mais importante é que você precisa roda-los dentro da pasta correta do Rails, se você entrar nesta pasta e rodar o `rails runner` não vai funcionar, então o comando correto é dentro da pasta `./api`, se os comandos ficarem muito compridos e você usar frequentemente, use um aliase para facilitar.

`rails runner ./rails_runner_testes/check_s3_env.rb`

## Testes AWS S3
- Checar configuração da S3 (env) -> `rails runner ./rails_runner_testes/check_s3_env.rb`
- Checar acesso aos profiles pictures da Legal Data API através do Rails -> `rails runner ./rails_runner_testes/legal_data_s3_profile_picture_download.rb`
