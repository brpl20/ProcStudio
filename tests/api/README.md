# API Tests

Testes diretos de API.

## Customer
npx mocha ./api/Customers/customers_test.js --reporter spec
npx mocha ./api/Customers/customers_test.js

Testes:
- Criar um novo registro
- Listar todos os registros
- Consultar um registro
- Atualizar um registro aleatório
- Deletar um registro
- Verificar isolabilidade de registros por User
