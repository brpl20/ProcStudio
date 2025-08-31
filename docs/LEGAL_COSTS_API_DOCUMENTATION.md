# Legal Costs API Documentation

## Overview
The Legal Costs system allows managing legal expenses associated with honoraries in the system. Each honorary can have one legal cost record with multiple cost entries.

## Models Structure

### LegalCost
- Belongs to Honorary (one-to-one)
- Has many LegalCostEntries
- Tracks who is responsible for costs and admin fees

### LegalCostEntry
- Belongs to LegalCost
- Belongs to LegalCostType
- Tracks individual cost items with amounts, due dates, and payment status

### LegalCostType
- System-wide or team-specific cost type definitions
- Used to categorize and standardize cost entries

## API Endpoints

### 1. Create Legal Cost
```
POST /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost
```

Request body:
```json
{
  "legal_cost": {
    "client_responsible": true,
    "include_in_invoices": true,
    "admin_fee_percentage": 10.0
  }
}
```

### 2. Get Legal Cost
```
GET /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost
```

### 3. Update Legal Cost
```
PUT /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost
```

### 4. Delete Legal Cost
```
DELETE /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost
```

### 5. Create Legal Cost Entry
```
POST /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost/entries
```

Request body:
```json
{
  "legal_cost_entry": {
    "legal_cost_type_id": 1,
    "name": "Custas iniciais do processo",
    "amount": 850.00,
    "estimated": false,
    "due_date": "2025-09-30",
    "description": "Pagamento das custas iniciais para protocolo"
  }
}
```

### 6. List Legal Cost Entries
```
GET /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost/entries
```

Query parameters:
- `cost_type`: Filter by cost type
- `paid`: Filter by payment status (true/false)
- `estimated`: Filter by estimation status (true/false)
- `overdue`: Show only overdue entries (true)
- `upcoming`: Show only upcoming entries (true)

### 7. Update Legal Cost Entry
```
PUT /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost/entries/:id
```

### 8. Delete Legal Cost Entry
```
DELETE /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost/entries/:id
```

### 9. Mark Entry as Paid
```
POST /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost/entries/:id/mark_as_paid
```

Request body (optional):
```json
{
  "payment_date": "2025-08-31",
  "receipt_number": "REC-001",
  "payment_method": "credit_card"
}
```

### 10. Mark Entry as Unpaid
```
POST /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost/entries/:id/mark_as_unpaid
```

### 11. Batch Create Entries
```
POST /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost/entries/batch_create
```

Request body:
```json
{
  "entries": [
    {
      "legal_cost_type_id": 1,
      "name": "Entry 1",
      "amount": 100.00
    },
    {
      "legal_cost_type_id": 2,
      "name": "Entry 2", 
      "amount": 200.00
    }
  ]
}
```

### 12. Get Entries by Type
```
GET /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost/entries/by_type
```

### 13. Legal Cost Summary
```
GET /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost/summary
```

### 14. Overdue Entries
```
GET /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost/overdue_entries
```

### 15. Upcoming Entries
```
GET /api/v1/works/:work_id/honoraries/:honorary_id/legal_cost/upcoming_entries
```

Query parameters:
- `days`: Number of days ahead to look (default: 30)

## Authentication
All endpoints require JWT authentication token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

## Response Format
All responses use JSON:API format with data, relationships, and meta information.

## Status Codes
- 200: Success (GET, PUT)
- 201: Created (POST)
- 204: No Content (DELETE)
- 401: Unauthorized
- 404: Not Found
- 422: Unprocessable Entity (validation errors)
- 500: Internal Server Error

## Example Usage

### Complete Flow
1. Create a legal cost for an honorary
2. Add multiple cost entries
3. Track payment status
4. Generate summaries and reports

### Testing with cURL
```bash
# Login
TOKEN=$(curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"auth": {"email": "u1@gmail.com", "password": "123456"}}' \
  | jq -r '.data.token')

# Create legal cost
curl -X POST http://localhost:3000/api/v1/works/35/honoraries/10/legal_cost \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "legal_cost": {
      "client_responsible": true,
      "include_in_invoices": true,
      "admin_fee_percentage": 10.0
    }
  }'

# Add entry
curl -X POST http://localhost:3000/api/v1/works/35/honoraries/10/legal_cost/entries \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "legal_cost_entry": {
      "legal_cost_type_id": 1,
      "name": "Court fees",
      "amount": 850.00,
      "due_date": "2025-09-30"
    }
  }'
```