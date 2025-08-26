# Represents API Guide - Managing Legal Representations

## Overview
This guide explains how to create and manage legal representations between customers, supporting scenarios where unable persons (minors) or relatively incapable persons need legal representatives.

## Key Concepts

### Capacity Types
- **able**: Fully capable (18+ years)
- **relatively**: Relatively incapable (16-17 years)
- **unable**: Absolutely incapable (0-15 years)

### Relationship Types
- **representation**: Full legal representation (for unable persons)
- **assistance**: Legal assistance (for relatively incapable persons)
- **curatorship**: Court-appointed curator
- **tutorship**: Court-appointed tutor

### Multiple Representors Support
- One customer can have multiple active representors (e.g., both parents)
- Each representation is tracked independently
- Representations are team-scoped

## API Endpoints

### 1. Create Profile Customer (Unable Person)
```http
POST /api/v1/profile_customers
```

**Request Body:**
```json
{
  "profile_customer": {
    "customer_type": "physical_person",
    "name": "João",
    "last_name": "Silva",
    "cpf": "123.456.789-00",
    "rg": "12345678",
    "birth": "2010-05-15",
    "gender": "male",
    "civil_status": "single",
    "nationality": "brazilian",
    "capacity": "unable",
    "mother_name": "Maria Silva",
    "customer_attributes": {
      "email": "",  // Optional for unable persons
      "password": "auto_generated"
    },
    "addresses_attributes": [{
      "street": "Rua Example",
      "number": "123",
      "city": "São Paulo",
      "state": "SP"
    }]
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Perfil de cliente criado com sucesso",
  "data": {
    "id": 1,
    "attributes": {
      "name": "João Silva",
      "capacity": "unable"
    }
  }
}
```

### 2. Create Profile Customer (Representative)
```http
POST /api/v1/profile_customers
```

**Request Body:**
```json
{
  "profile_customer": {
    "customer_type": "representative",
    "name": "Maria",
    "last_name": "Silva",
    "cpf": "987.654.321-00",
    "rg": "87654321",
    "birth": "1985-03-20",
    "gender": "female",
    "civil_status": "married",
    "nationality": "brazilian",
    "capacity": "able",
    "profession": "Professora",
    "mother_name": "Ana Silva",
    "customer_attributes": {
      "email": "maria@example.com",
      "password": "secure_password123"
    }
  }
}
```

### 3. Create Representation Relationship
```http
POST /api/v1/represents
```

**Request Body:**
```json
{
  "represent": {
    "profile_customer_id": 1,  // ID of the unable/relatively incapable person
    "representor_id": 2,        // ID of the representative
    "relationship_type": "representation",
    "active": true,
    "start_date": "2024-01-01",
    "notes": "Mãe do menor"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Representação criada com sucesso",
  "data": {
    "id": 1,
    "profile_customer_id": 1,
    "profile_customer_name": "João Silva",
    "representor_id": 2,
    "representor_name": "Maria Silva",
    "relationship_type": "representation",
    "active": true,
    "start_date": "2024-01-01",
    "profile_customer": {
      "id": 1,
      "name": "João Silva",
      "capacity": "unable"
    },
    "representor": {
      "id": 2,
      "name": "Maria Silva",
      "profession": "Professora"
    }
  }
}
```

## Complete Frontend Implementation Example

### Creating Unable Person with Multiple Representatives (e.g., Both Parents)

```javascript
async function createUnablePersonWithRepresentatives() {
  try {
    // Step 1: Create the unable person (child)
    const childResponse = await api.post('/api/v1/profile_customers', {
      profile_customer: {
        name: "João",
        last_name: "Silva Santos",
        cpf: "123.456.789-00",
        birth: "2010-05-15",
        capacity: "unable",
        // ... other fields
      }
    });
    
    const childId = childResponse.data.data.id;
    
    // Step 2: Create first representative (mother)
    const motherResponse = await api.post('/api/v1/profile_customers', {
      profile_customer: {
        customer_type: "representative",
        name: "Maria",
        last_name: "Silva",
        cpf: "987.654.321-00",
        capacity: "able",
        profession: "Professora",
        // ... other fields
      }
    });
    
    const motherId = motherResponse.data.data.id;
    
    // Step 3: Create second representative (father)
    const fatherResponse = await api.post('/api/v1/profile_customers', {
      profile_customer: {
        customer_type: "representative",
        name: "José",
        last_name: "Santos",
        cpf: "456.789.123-00",
        capacity: "able",
        profession: "Engenheiro",
        // ... other fields
      }
    });
    
    const fatherId = fatherResponse.data.data.id;
    
    // Step 4: Create representation relationships
    const motherRelationship = await api.post('/api/v1/represents', {
      represent: {
        profile_customer_id: childId,
        representor_id: motherId,
        relationship_type: "representation",
        active: true,
        notes: "Mãe"
      }
    });
    
    const fatherRelationship = await api.post('/api/v1/represents', {
      represent: {
        profile_customer_id: childId,
        representor_id: fatherId,
        relationship_type: "representation",
        active: true,
        notes: "Pai"
      }
    });
    
    return {
      child: childResponse.data,
      mother: motherResponse.data,
      father: fatherResponse.data,
      relationships: [motherRelationship.data, fatherRelationship.data]
    };
    
  } catch (error) {
    console.error('Error creating representation:', error);
    throw error;
  }
}
```

## Other Useful Endpoints

### List All Representations for a Customer
```http
GET /api/v1/profile_customers/:profile_customer_id/represents
```

### List All Customers Represented by a Person
```http
GET /api/v1/represents/by_representor/:representor_id
```

### Update Representation
```http
PATCH /api/v1/represents/:id
```

### Deactivate Representation
```http
POST /api/v1/represents/:id/deactivate
```

### Reactivate Representation
```http
POST /api/v1/represents/:id/reactivate
```

### Delete Representation
```http
DELETE /api/v1/represents/:id
```

## Important Business Rules

1. **Email Validation**: Unable persons (capacity = 'unable') can have empty emails or share emails with their guardians
2. **Profession Field**: Not required for unable persons, required for all others
3. **Multiple Representatives**: One customer can have multiple active representatives
4. **Representative Capacity**: Representatives must be legally capable (capacity = 'able')
5. **Self-Representation**: A person cannot represent themselves
6. **Team Scoping**: All representations are scoped to the current team

## Error Handling

Common error responses:

```json
{
  "success": false,
  "message": "Erro ao criar representação",
  "errors": [
    "Representor deve ser legalmente capaz (maior de 18 anos)",
    "Representor já está representando este cliente"
  ]
}
```

## Compliance Notifications

The system automatically creates compliance notifications when:
- A new representation is established
- A representation is terminated
- A customer's capacity changes

These notifications help track legal changes that may require document updates.