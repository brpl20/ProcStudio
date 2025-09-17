[Back](../README.md)

# Test

Os testes são centralizados na pasta `./tests` exceto os testes unitários de Rails que precisam ficar na pasta do próprio sistema e incluem:

- API tests: Testes diretos com a API
- API Svelte: Testes para verificar a conexão entre Svelte e Rails
- Rails: Testes unitários de backend
- E2E: Testes feitos para ver a integridade do sistema o início ao fim

# API

* Index should be a facade design pattern that will include all tests
* All tests should be run with one command: example `npx mocha ./api/ProfileCustomers/tests.js`
* But tests should be possible with one command for each test also `npx mocha./api/ProfileCustomers/tests.js --create`

Vá até a pasta de testes e execute-os ou visualize o código...

Por enquanto os testes mais completos são o da API para:

## BackendInspector
Esse é um arquivo de teste para verificar se existem atualizações na `/api` com relação aos arquivos de testes. Isso é importante porque não queremos fazer testes com base em arquivos novos com testes antigos. O ideal é que no momento da implementação os testes já sejam atualizados, mas este é um mecanismo extra para ajudar a termos mais segurança e facilidade na criação dos testes. Esse arquivo terá um cache para armazenar dados necessários a essa verificação: `.backend_cache.json`.

Exemplo de backendinspector: `.tests/api/ProfileCustomers/backend_inspector.js` e `/inspect.js`.

Uso:
```js
"test:standalone-inspection": "node ./api/ProfileCustomers/inspect.js"
"test:options - With options: -v (verbose), -q (quiet), --clear-cache"
```

## Profile Customer

Use `--reporter min` para resultados mais simplificados: _Funciona em todos os métodos._

```js
"test:profile-customers": "npx mocha ./api/ProfileCustomers/tests.js --reporter min"
"test:profile-customers:create": "npx mocha ./api/ProfileCustomers/tests.js --create"
"test:profile-customers:read": "npx mocha ./api/ProfileCustomers/tests.js --read"
"test:profile-customers:update": "npx mocha ./api/ProfileCustomers/tests.js --update"
"test:profile-customers:delete-soft": "npx mocha ./api/ProfileCustomers/tests.js --delete-soft"
"test:profile-customers:delete-hard": "npx mocha ./api/ProfileCustomers/tests.js --delete-hard"
"test:profile-customers:isolation": "npx mocha ./api/ProfileCustomers/tests.js --isolation"
```
