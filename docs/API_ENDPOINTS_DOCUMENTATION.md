# API Endpoints Documentation

## Base URL
`/api/v1`

## Authentication
All endpoints require authentication via JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

---

## 1. PROCEDURES ENDPOINTS

### 1.1 List Work Procedures
```
GET /works/:work_id/procedures
```
**Query Parameters:**
- `procedure_type`: Filter by type (administrativo, judicial, extrajudicial)
- `status`: Filter by status (in_progress, paused, completed, archived)
- `system`: Filter by system (INSS, Eproc, Projudi, etc.)
- `competence`: Filter by competence
- `priority`: true/false - Filter priority procedures

**Response:** Array of procedures with metadata

### 1.2 Get Procedure Details
```
GET /works/:work_id/procedures/:id
```
**Response:** Single procedure with associated data

### 1.3 Create Procedure
```
POST /works/:work_id/procedures
```
**Body:**
```json
{
  "procedure": {
    "procedure_type": "judicial",
    "law_area_id": 1,
    "number": "1234567-89.2024.8.16.0000",
    "city": "Cascavel",
    "state": "PR",
    "system": "Projudi",
    "competence": "Justiça Estadual",
    "start_date": "2024-01-01",
    "end_date": null,
    "procedure_class": "Pequenas Causas",
    "responsible": "Dr. João Silva",
    "claim_value": 50000.00,
    "conviction_value": null,
    "received_value": null,
    "status": "in_progress",
    "justice_free": false,
    "conciliation": true,
    "priority": false,
    "priority_type": null,
    "notes": "Observações do procedimento"
  }
}
```

### 1.4 Update Procedure
```
PUT /works/:work_id/procedures/:id
```
**Body:** Same as create

### 1.5 Delete Procedure
```
DELETE /works/:work_id/procedures/:id
```

### 1.6 Create Child Procedure
```
POST /works/:work_id/procedures/:procedure_id/create_child
```
**Body:** Same as create procedure

### 1.7 Get Procedures Tree
```
GET /works/:work_id/procedures/tree
```
**Response:** Hierarchical tree structure of procedures

### 1.8 Get Financial Summary
```
GET /works/:work_id/procedures/:procedure_id/financial_summary
```
**Response:**
```json
{
  "data": {
    "claim_value": 50000.00,
    "conviction_value": 30000.00,
    "received_value": 25000.00,
    "pending_value": 5000.00,
    "has_financial_values": true
  }
}
```

---

## 2. PROCEDURAL PARTIES ENDPOINTS

### 2.1 List Procedure Parties
```
GET /works/:work_id/procedures/:procedure_id/procedural_parties
```
**Query Parameters:**
- `party_type`: plaintiff or defendant

### 2.2 Get Party Details
```
GET /works/:work_id/procedures/:procedure_id/procedural_parties/:id
```

### 2.3 Create Procedural Party
```
POST /works/:work_id/procedures/:procedure_id/procedural_parties
```
**Body:**
```json
{
  "procedural_party": {
    "party_type": "plaintiff",
    "partyable_type": "ProfileCustomer",
    "partyable_id": 123,
    "name": "João da Silva",
    "cpf_cnpj": "123.456.789-00",
    "oab_number": null,
    "is_primary": true,
    "represented_by": "Dr. Maria Santos",
    "notes": "Cliente principal"
  }
}
```

### 2.4 Update Procedural Party
```
PUT /works/:work_id/procedures/:procedure_id/procedural_parties/:id
```

### 2.5 Delete Procedural Party
```
DELETE /works/:work_id/procedures/:procedure_id/procedural_parties/:id
```

### 2.6 Set as Primary Party
```
POST /works/:work_id/procedures/:procedure_id/procedural_parties/:party_id/set_primary
```

### 2.7 Reorder Parties
```
PUT /works/:work_id/procedures/:procedure_id/procedural_parties/reorder
```
**Body:**
```json
{
  "order": [3, 1, 2, 4]
}
```

---

## 3. HONORARIES ENDPOINTS

### 3.1 Work-Level (Global) Honoraries

#### 3.1.1 List Work Honoraries
```
GET /works/:work_id/honoraries
```

#### 3.1.2 Get Honorary Details
```
GET /works/:work_id/honoraries/:id
```

#### 3.1.3 Create Work Honorary
```
POST /works/:work_id/honoraries
```
**Body:**
```json
{
  "honorary": {
    "name": "Honorários Contratuais",
    "description": "Honorários fixos do contrato",
    "status": "active",
    "honorary_type": "work"
  }
}
```

#### 3.1.4 Update Honorary
```
PUT /works/:work_id/honoraries/:id
```

#### 3.1.5 Delete Honorary
```
DELETE /works/:work_id/honoraries/:id
```

#### 3.1.6 Get Honorary Summary
```
GET /works/:work_id/honoraries/:honorary_id/summary
```

### 3.2 Procedure-Level Honoraries

#### 3.2.1 List Procedure Honoraries
```
GET /works/:work_id/procedures/:procedure_id/honoraries
```

#### 3.2.2 Create Procedure Honorary
```
POST /works/:work_id/procedures/:procedure_id/honoraries
```
**Body:** Same as work-level honorary

---

## 4. HONORARY COMPONENTS ENDPOINTS

### 4.1 List Components
```
GET /works/:work_id/honoraries/:honorary_id/components
```
**Query Parameters:**
- `active`: true/false
- `component_type`: Filter by type

### 4.2 Get Component Details
```
GET /works/:work_id/honoraries/:honorary_id/components/:id
```

### 4.3 Create Component
```
POST /works/:work_id/honoraries/:honorary_id/components
```
**Body Examples:**

**Fixed Fee:**
```json
{
  "component": {
    "component_type": "fixed_fee",
    "details": {
      "amount": 5000.00,
      "payment_terms": "À vista",
      "installments": 1
    }
  }
}
```

**Hourly Rate:**
```json
{
  "component": {
    "component_type": "hourly_rate",
    "details": {
      "rate": 500.00,
      "estimated_hours": 20,
      "minimum_hours": 10
    }
  }
}
```

**Success Fee:**
```json
{
  "component": {
    "component_type": "success_fee",
    "details": {
      "percentage": 30,
      "minimum_amount": 10000.00,
      "maximum_amount": 100000.00
    }
  }
}
```

### 4.4 Update Component
```
PUT /works/:work_id/honoraries/:honorary_id/components/:id
```

### 4.5 Delete Component
```
DELETE /works/:work_id/honoraries/:honorary_id/components/:id
```

### 4.6 Toggle Active Status
```
POST /works/:work_id/honoraries/:honorary_id/components/:id/toggle_active
```

### 4.7 Calculate Component Value
```
GET /works/:work_id/honoraries/:honorary_id/components/:component_id/calculate
```

### 4.8 Reorder Components
```
PUT /works/:work_id/honoraries/:honorary_id/components/reorder
```
**Body:**
```json
{
  "order": [2, 1, 3]
}
```

---

## 5. LEGAL COSTS ENDPOINTS

### 5.1 Get Legal Cost
```
GET /works/:work_id/honoraries/:honorary_id/legal_cost
```

### 5.2 Create Legal Cost
```
POST /works/:work_id/honoraries/:honorary_id/legal_cost
```
**Body:**
```json
{
  "legal_cost": {
    "client_responsible": true,
    "include_in_invoices": true,
    "admin_fee_percentage": 10.0
  }
}
```

### 5.3 Update Legal Cost
```
PUT /works/:work_id/honoraries/:honorary_id/legal_cost
```

### 5.4 Delete Legal Cost
```
DELETE /works/:work_id/honoraries/:honorary_id/legal_cost
```

### 5.5 Get Legal Cost Summary
```
GET /works/:work_id/honoraries/:honorary_id/legal_cost/summary
```

### 5.6 Get Overdue Entries
```
GET /works/:work_id/honoraries/:honorary_id/legal_cost/overdue_entries
```

### 5.7 Get Upcoming Entries
```
GET /works/:work_id/honoraries/:honorary_id/legal_cost/upcoming_entries
```
**Query Parameters:**
- `days`: Number of days ahead (default: 30)

---

## 6. LEGAL COST ENTRIES ENDPOINTS

### 6.1 List Entries
```
GET /works/:work_id/honoraries/:honorary_id/legal_cost/entries
```
**Query Parameters:**
- `cost_type`: Filter by type
- `paid`: true/false
- `estimated`: true/false
- `overdue`: true/false
- `upcoming`: true/false

### 6.2 Get Entry Details
```
GET /works/:work_id/honoraries/:honorary_id/legal_cost/entries/:id
```

### 6.3 Create Entry
```
POST /works/:work_id/honoraries/:honorary_id/legal_cost/entries
```
**Body:**
```json
{
  "entry": {
    "cost_type": "custas_judiciais",
    "name": "Custas Iniciais",
    "description": "Custas para distribuição do processo",
    "amount": 500.00,
    "estimated": false,
    "paid": false,
    "due_date": "2024-12-31",
    "payment_date": null,
    "receipt_number": null,
    "payment_method": null
  }
}
```

### 6.4 Update Entry
```
PUT /works/:work_id/honoraries/:honorary_id/legal_cost/entries/:id
```

### 6.5 Delete Entry
```
DELETE /works/:work_id/honoraries/:honorary_id/legal_cost/entries/:id
```

### 6.6 Mark Entry as Paid
```
POST /works/:work_id/honoraries/:honorary_id/legal_cost/entries/:id/mark_as_paid
```
**Body:**
```json
{
  "payment_date": "2024-01-15",
  "receipt_number": "REC-12345",
  "payment_method": "Boleto"
}
```

### 6.7 Mark Entry as Unpaid
```
POST /works/:work_id/honoraries/:honorary_id/legal_cost/entries/:id/mark_as_unpaid
```

### 6.8 Batch Create Entries
```
POST /works/:work_id/honoraries/:honorary_id/legal_cost/entries/batch_create
```
**Body:**
```json
{
  "entries": [
    {
      "cost_type": "custas_judiciais",
      "name": "Custas Iniciais",
      "amount": 500.00
    },
    {
      "cost_type": "taxa_judiciaria",
      "name": "Taxa de Distribuição",
      "amount": 250.00
    }
  ]
}
```

### 6.9 Get Entries by Type
```
GET /works/:work_id/honoraries/:honorary_id/legal_cost/entries/by_type
```

---

## COST TYPES REFERENCE

Available Brazilian legal cost types:
- `custas_judiciais` - Custas Judiciais
- `taxa_judiciaria` - Taxa Judiciária
- `diligencia_oficial` - Diligência de Oficial de Justiça
- `guia_darf` - Guia DARF
- `guia_gps` - Guia GPS
- `guia_recolhimento_oab` - Guia de Recolhimento OAB
- `despesas_cartorarias` - Despesas Cartorárias
- `imposto_de_renda_advocacia` - Imposto de Renda - Serviços Advocatícios
- `iss` - ISS - Imposto sobre Serviços
- `distribuicao` - Taxa de Distribuição
- `certidoes` - Certidões
- `autenticacoes` - Autenticações
- `reconhecimento_firma` - Reconhecimento de Firma
- `edital` - Publicação de Edital
- `pericia` - Honorários Periciais
- `taxa_recursal` - Taxa de Recurso
- `deposito_recursal` - Depósito Recursal
- `preparo` - Preparo
- `porte_remessa` - Porte de Remessa e Retorno
- `outros` - Outros

---

## COMPONENT TYPES REFERENCE

Available honorary component types:
- `fixed_fee` - Fixed fee amount
- `hourly_rate` - Hourly billing rate
- `monthly_retainer` - Monthly retainer fee
- `success_fee` - Success/contingency fee
- `performance_fee` - Performance-based fee
- `consultation_fee` - Consultation fee
- `previdenciario_fee` - Social security specific fee
- `sucumbencia_fee` - Brazilian loser-pays fee

---

## ERROR RESPONSES

All endpoints return standard error responses:

### 400 Bad Request
```json
{
  "errors": ["Field is required", "Invalid value"]
}
```

### 401 Unauthorized
```json
{
  "error": "Unauthorized"
}
```

### 404 Not Found
```json
{
  "error": "Record not found"
}
```

### 422 Unprocessable Entity
```json
{
  "errors": ["Validation error messages"]
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error"
}
```