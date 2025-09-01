# Exemplos de Requisições para Custos Legais - Postman

## 1. Primeiro, obter informações do Work e seus honorários

### GET Work com Honorários
```
GET http://localhost:3000/api/v1/works/35
Authorization: Bearer {{token}}
```

## 2. Verificar/Criar LegalCost para o Honorary

### GET Honorary com LegalCost
```
GET http://localhost:3000/api/v1/works/35/honoraries
Authorization: Bearer {{token}}
```

Assumindo que o honorary tem ID 1 (você precisa pegar o ID real da resposta acima)

### POST Criar LegalCost se não existir
```
POST http://localhost:3000/api/v1/honoraries/1/legal_cost
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "legal_cost": {
    "client_responsible": true,
    "include_in_invoices": true,
    "admin_fee_percentage": 10.0
  }
}
```

## 3. Adicionar Legal Cost Entries

### POST Adicionar uma única entry
```
POST http://localhost:3000/api/v1/honoraries/1/legal_cost/entries
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "legal_cost_entry": {
    "legal_cost_type_id": 1,  // ID do tipo "custas_judiciais"
    "name": "Custas Iniciais do Processo",
    "amount": 850.00,
    "description": "Pagamento das custas iniciais para protocolo da ação",
    "estimated": false,
    "due_date": "2025-09-15",
    "paid": false
  }
}
```

### POST Adicionar múltiplas entries de uma vez
```
POST http://localhost:3000/api/v1/honoraries/1/legal_cost/entries/batch_create
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "legal_cost_entries": [
    {
      "legal_cost_type_id": 1,  // Custas Judiciais
      "name": "Custas Iniciais",
      "amount": 850.00,
      "description": "Custas para protocolo inicial",
      "estimated": false,
      "due_date": "2025-09-15",
      "paid": false
    },
    {
      "legal_cost_type_id": 2,  // Taxa Judiciária
      "name": "Taxa TJPR",
      "amount": 450.00,
      "description": "Taxa judiciária estadual obrigatória",
      "estimated": false,
      "due_date": "2025-09-10",
      "paid": false
    },
    {
      "legal_cost_type_id": 3,  // Diligência Oficial
      "name": "Citação do Réu",
      "amount": 120.00,
      "description": "Diligência para citação da parte contrária",
      "estimated": true,
      "due_date": "2025-09-20",
      "paid": false
    },
    {
      "legal_cost_type_id": 15,  // Certidões
      "name": "Certidão de Distribuição",
      "amount": 35.00,
      "description": "Certidão de distribuição de ações",
      "estimated": false,
      "due_date": "2025-09-05",
      "paid": true,
      "payment_date": "2025-08-30",
      "receipt_number": "CERT-2025-12345",
      "payment_method": "PIX"
    },
    {
      "legal_cost_type_id": 9,  // Honorários Periciais
      "name": "Perícia Contábil",
      "amount": 5000.00,
      "description": "Honorários do perito contador nomeado",
      "estimated": true,
      "due_date": "2025-10-01",
      "paid": false
    }
  ]
}
```

## 4. Marcar uma entry como paga

### POST Marcar como pago
```
POST http://localhost:3000/api/v1/honoraries/1/legal_cost/entries/{{entry_id}}/mark_as_paid
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "payment_date": "2025-08-31",
  "receipt_number": "REC-2025-98765",
  "payment_method": "Transferência Bancária"
}
```

## 5. Listar todas as entries de custos

### GET Todas as entries
```
GET http://localhost:3000/api/v1/honoraries/1/legal_cost/entries
Authorization: Bearer {{token}}
```

### GET Apenas entries pendentes
```
GET http://localhost:3000/api/v1/honoraries/1/legal_cost/entries?status=pending
Authorization: Bearer {{token}}
```

### GET Entries por tipo
```
GET http://localhost:3000/api/v1/honoraries/1/legal_cost/entries/by_type?type=custas_judiciais
Authorization: Bearer {{token}}
```

## 6. Obter resumo financeiro

### GET Resumo do LegalCost
```
GET http://localhost:3000/api/v1/honoraries/1/legal_cost
Authorization: Bearer {{token}}
```

Resposta esperada incluirá:
- Total geral
- Total pago
- Total pendente
- Total vencido
- Taxa administrativa
- Total com taxa

---

## EXEMPLO COMPLETO PARA POSTMAN (RAW)

Cole isso diretamente no Postman como raw request:

### Requisição 1: Listar tipos de custos disponíveis
```http
GET /api/v1/legal_cost_types HTTP/1.1
Host: localhost:3000
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo1LCJhZG1pbl9pZCI6NSwiZXhwIjoxNzU2NzMyNDc5LCJuYW1lIjoiQnJ1bm8iLCJsYXN0X25hbWUiOiJQZWxsaXp6ZXR0aSIsInJvbGUiOiJsYXd5ZXIifQ.HOYu-b22kS6HwzADDA6Pb0KuK-p7o0kIBXoddZlEEsU
Content-Type: application/json
```

### Requisição 2: Criar custos para um honorary (substitua o ID do honorary)
```http
POST /api/v1/honoraries/1/legal_cost/entries/batch_create HTTP/1.1
Host: localhost:3000
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo1LCJhZG1pbl9pZCI6NSwiZXhwIjoxNzU2NzMyNDc5LCJuYW1lIjoiQnJ1bm8iLCJsYXN0X25hbWUiOiJQZWxsaXp6ZXR0aSIsInJvbGUiOiJsYXd5ZXIifQ.HOYu-b22kS6HwzADDA6Pb0KuK-p7o0kIBXoddZlEEsU
Content-Type: application/json

{
  "legal_cost_entries": [
    {
      "legal_cost_type_id": 1,
      "name": "Custas Processuais Iniciais",
      "amount": 850.00,
      "description": "Custas para protocolo da petição inicial",
      "estimated": false,
      "due_date": "2025-09-15",
      "paid": false
    },
    {
      "legal_cost_type_id": 2,
      "name": "Taxa Judiciária TJPR",
      "amount": 450.00,
      "description": "Taxa estadual obrigatória",
      "estimated": false,
      "due_date": "2025-09-10",
      "paid": false
    },
    {
      "legal_cost_type_id": 9,
      "name": "Perícia Técnica",
      "amount": 3500.00,
      "description": "Honorários periciais estimados",
      "estimated": true,
      "due_date": "2025-10-01",
      "paid": false
    }
  ]
}
```

### Requisição 3: Marcar um custo como pago
```http
POST /api/v1/honoraries/1/legal_cost/entries/1/mark_as_paid HTTP/1.1
Host: localhost:3000
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo1LCJhZG1pbl9pZCI6NSwiZXhwIjoxNzU2NzMyNDc5LCJuYW1lIjoiQnJ1bm8iLCJsYXN0X25hbWUiOiJQZWxsaXp6ZXR0aSIsInJvbGUiOiJsYXd5ZXIifQ.HOYu-b22kS6HwzADDA6Pb0KuK-p7o0kIBXoddZlEEsU
Content-Type: application/json

{
  "payment_date": "2025-08-31",
  "receipt_number": "GRU-2025-123456",
  "payment_method": "PIX"
}
```

---

## NOTAS IMPORTANTES:

1. **IDs dos tipos de custos**: Use o endpoint `/api/v1/legal_cost_types` para obter os IDs corretos
2. **ID do Honorary**: Você precisa primeiro obter o ID do honorary do Work 35
3. **Token**: Use seu token de autenticação válido
4. **Datas**: Ajuste as datas conforme necessário
5. **Valores**: Os valores são exemplos, ajuste conforme a realidade do processo

O fluxo correto é:
1. Work → 2. Honorary → 3. LegalCost → 4. LegalCostEntries