[Back](../README.md)

# User & UserProfile

Users é apenas para o registro, UserProfile para as demais informações. Isso gera uma camada adicional de complexidade no nosso sistema. Dá mais trabalho para fazer a requisição entre User e UserProfile, porém optamos por deixar nesta metodologia para facilitar o acesso inicial do usuário no sistema, cadastrando apenas seu email, senha e número da oab.

## API

Confira os métodos de API no Postman para compreender melhor. Apenas note que temos um serializer específico `full_user_serializer.rb` para combinar as informações dos dois modelos, facilitando um pouco a questão das requisições, inclusios em seus métodos estão:

```md
GET /api/v1/whoami
GET /api/v1/user_info/:identifier { User ID or UserProfile ID }
GET /api/v1/user_by_profile/:profile_id
GET /api/v1/user_by_id/:user_id
```
