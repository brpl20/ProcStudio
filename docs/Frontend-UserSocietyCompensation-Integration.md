[Back](../README.md)

# Frontend Integration Guide: UserSocietyCompensation

This guide explains how to integrate the new UserSocietyCompensation model with your frontend API requests.

## Overview

The compensation model has been updated to support:
- **Compensation Types**: Only `pro_labore` and `salary` (removed `proportional`)
- **Office-level Proportional Setting**: Moved to `office.proportional` boolean field
- **Nested Compensation Creation**: Through `user_offices` nested attributes

## API Request Structure

### Creating an Office with Partner Compensations

```json
{
  "office": {
    "name": "Amber Knight Law Office",
    "cnpj": "04846378687531",
    "site": "https://www.amberlaw.com",
    "quote_value": "26.0",
    "number_of_quotes": 668,
    "proportional": true,
    "society": "company",
    "foundation": "1978-08-28",
    "accounting_type": "presumed_profit",
    "oab_id": "12345",
    "oab_inscricao": "OAB/PR 12345",
    "oab_link": "https://oab.org.br",
    "oab_status": "active",
    
    "addresses_attributes": [
      {
        "zip_code": "85810240",
        "street": "Rua das Flores",
        "number": "175",
        "complement": "Sala 101",
        "neighborhood": "Centro",
        "city": "Cascavel",
        "state": "PR",
        "address_type": "main"
      }
    ],
    
    "phones_attributes": [
      {
        "phone_number": "17599594983"
      }
    ],
    
    "emails_attributes": [
      {
        "email": "contact@amberlaw.com",
        "email_type": "main"
      }
    ],
    
    "user_offices_attributes": [
      {
        "user_id": 1,
        "partnership_type": "socio",
        "partnership_percentage": 60.0,
        "is_administrator": true,
        "entry_date": "2023-01-01",
        
        "compensations_attributes": [
          {
            "compensation_type": "pro_labore",
            "amount": 5000.00,
            "payment_frequency": "monthly",
            "effective_date": "2024-01-01",
            "notes": "Pro-labore administrativo"
          }
        ]
      },
      {
        "user_id": 2,
        "partnership_type": "socio",
        "partnership_percentage": 40.0,
        "is_administrator": false,
        "entry_date": "2023-06-01",
        
        "compensations_attributes": [
          {
            "compensation_type": "salary",
            "amount": 8000.00,
            "payment_frequency": "monthly",
            "effective_date": "2024-01-01",
            "end_date": "2024-12-31",
            "notes": "Salário fixo anual"
          }
        ]
      }
    ]
  }
}
```

### Frontend Form Structure

#### 1. Office Basic Information

```javascript
const officeForm = {
  // Basic office data
  name: '',
  cnpj: '',
  site: '',
  quote_value: 0,
  number_of_quotes: 0,
  proportional: false,  // NEW: Office-level proportional setting
  society: 'company',   // 'individual' or 'company'
  foundation: '',
  accounting_type: 'simple',
  
  // OAB Information
  oab_id: '',
  oab_inscricao: '',
  oab_link: '',
  oab_status: 'active',
  
  // Nested associations
  addresses_attributes: [],
  phones_attributes: [],
  emails_attributes: [],
  user_offices_attributes: []
}
```

#### 2. Partner and Compensation Form

```javascript
const partnerForm = {
  user_id: null,
  partnership_type: 'socio',        // 'socio', 'associado', 'socio_de_servico'
  partnership_percentage: 0,
  is_administrator: false,
  entry_date: '',
  
  compensations_attributes: [
    {
      compensation_type: 'pro_labore', // Only 'pro_labore' or 'salary'
      amount: 0,
      payment_frequency: 'monthly',    // 'monthly', 'quarterly', 'semi_annually', 'annually'
      effective_date: '',
      end_date: null,                  // Optional
      notes: ''                        // Optional
    }
  ]
}
```

## Frontend Implementation Examples

### React/JavaScript Example

```javascript
// CompensationForm.jsx
import React, { useState } from 'react';

const CompensationForm = ({ partnerId, onCompensationChange }) => {
  const [compensation, setCompensation] = useState({
    compensation_type: 'pro_labore',
    amount: '',
    payment_frequency: 'monthly',
    effective_date: '',
    end_date: '',
    notes: ''
  });

  const compensationTypes = [
    { value: 'pro_labore', label: 'Pró-labore' },
    { value: 'salary', label: 'Salário' }
  ];

  const paymentFrequencies = [
    { value: 'monthly', label: 'Mensal' },
    { value: 'quarterly', label: 'Trimestral' },
    { value: 'semi_annually', label: 'Semestral' },
    { value: 'annually', label: 'Anual' }
  ];

  const handleChange = (field, value) => {
    const updated = { ...compensation, [field]: value };
    setCompensation(updated);
    onCompensationChange(partnerId, updated);
  };

  return (
    <div className="compensation-form">
      <h4>Remuneração do Sócio</h4>
      
      <div className="form-group">
        <label>Tipo de Remuneração:</label>
        <select 
          value={compensation.compensation_type}
          onChange={(e) => handleChange('compensation_type', e.target.value)}
        >
          {compensationTypes.map(type => (
            <option key={type.value} value={type.value}>
              {type.label}
            </option>
          ))}
        </select>
      </div>

      <div className="form-group">
        <label>Valor (R$):</label>
        <input
          type="number"
          step="0.01"
          value={compensation.amount}
          onChange={(e) => handleChange('amount', parseFloat(e.target.value))}
        />
      </div>

      <div className="form-group">
        <label>Frequência de Pagamento:</label>
        <select 
          value={compensation.payment_frequency}
          onChange={(e) => handleChange('payment_frequency', e.target.value)}
        >
          {paymentFrequencies.map(freq => (
            <option key={freq.value} value={freq.value}>
              {freq.label}
            </option>
          ))}
        </select>
      </div>

      <div className="form-group">
        <label>Data de Início:</label>
        <input
          type="date"
          value={compensation.effective_date}
          onChange={(e) => handleChange('effective_date', e.target.value)}
        />
      </div>

      <div className="form-group">
        <label>Data de Fim (opcional):</label>
        <input
          type="date"
          value={compensation.end_date}
          onChange={(e) => handleChange('end_date', e.target.value)}
        />
      </div>

      <div className="form-group">
        <label>Observações:</label>
        <textarea
          value={compensation.notes}
          onChange={(e) => handleChange('notes', e.target.value)}
          rows="3"
        />
      </div>
    </div>
  );
};

export default CompensationForm;
```

### Office Form with Proportional Setting

```javascript
// OfficeForm.jsx
const OfficeForm = () => {
  const [office, setOffice] = useState({
    proportional: false,
    user_offices_attributes: []
  });

  const handleProportionalChange = (value) => {
    setOffice(prev => ({
      ...prev,
      proportional: value
    }));
  };

  return (
    <form>
      {/* Basic office fields... */}
      
      <div className="form-group">
        <label>
          <input
            type="checkbox"
            checked={office.proportional}
            onChange={(e) => handleProportionalChange(e.target.checked)}
          />
          Distribuição Proporcional de Lucros
        </label>
        <small className="help-text">
          Quando ativado, os lucros serão distribuídos proporcionalmente 
          às participações dos sócios
        </small>
      </div>

      {/* Partners section */}
      {office.user_offices_attributes.map((partner, index) => (
        <PartnerForm 
          key={index}
          partner={partner}
          onPartnerChange={(updatedPartner) => updatePartner(index, updatedPartner)}
        />
      ))}
    </form>
  );
};
```

## API Response Structure

### Index View Response (Basic Information)

```json
{
  "data": {
    "id": "43",
    "type": "office",
    "attributes": {
      "name": "Amber Knight Law Office",
      "cnpj": "04846378687531",
      "site": "https://www.amberlaw.com",
      "quote_value": "26.0",
      "number_of_quotes": 668,
      "total_quotes_value": "17368.0",
      "proportional": true,
      "logo_url": null,
      "social_contracts_with_metadata": [],
      "city": "Cascavel",
      "state": "PR",
      "deleted": false
    }
  }
}
```

### Show View Response (Detailed with Compensations)

```json
{
  "data": {
    "id": "43",
    "type": "office",
    "attributes": {
      "name": "Amber Knight Law Office",
      "cnpj": "04846378687531",
      "proportional": true,
      "quote_value": "26.0",
      "number_of_quotes": 668,
      "society": "company",
      "foundation": "1978-08-28",
      "accounting_type": "presumed_profit",
      "oab_id": "12345",
      "oab_inscricao": "OAB/PR 12345",
      "oab_status": "active",
      "formatted_total_quotes_value": "R$ 17.368,00",
      
      "user_offices": [
        {
          "user_id": 1,
          "office_id": 43,
          "partnership_type": "socio",
          "partnership_percentage": 60.0,
          "is_administrator": true,
          "entry_date": "2023-01-01",
          "user_name": "João Silva",
          "user_email": "joao@example.com",
          "compensations": [
            {
              "compensation_type": "pro_labore",
              "amount": 5000.0,
              "amount_formatted": "R$ 5.000,00",
              "payment_frequency": "monthly",
              "effective_date": "2024-01-01",
              "end_date": null,
              "notes": "Pro-labore administrativo",
              "created_at": "2024-01-01T00:00:00.000-03:00",
              "updated_at": "2024-01-01T00:00:00.000-03:00"
            }
          ]
        }
      ],
      
      "partners_info": [
        {
          "number": 1,
          "partnership_type": "Sócio",
          "partnership_percentage": "60%",
          "is_administrator": true,
          "partner_quote_value": 96.25,
          "partner_quote_value_formatted": "R$ 96,25",
          "partner_number_of_quotes": 13.75,
          "partner_number_of_quotes_formatted": "13,75"
        }
      ],
      
      "partners_compensation": [
        {
          "number": 1,
          "lawyer_name": "JOÃO SILVA",
          "partnership_type": "Sócio",
          "partnership_percentage": "60%",
          "is_administrator": true,
          "compensation_type": "pro_labore",
          "compensation_amount": 5000.0,
          "compensation_amount_formatted": "R$ 5.000,00",
          "payment_frequency": "monthly",
          "effective_date": "2024-01-01",
          "end_date": null,
          "notes": "Pro-labore administrativo",
          "all_compensations": [
            {
              "type": "pro_labore",
              "amount": 5000.0,
              "amount_formatted": "R$ 5.000,00",
              "frequency": "monthly",
              "effective_date": "2024-01-01",
              "end_date": null,
              "notes": "Pro-labore administrativo"
            }
          ]
        }
      ],
      
      "is_proportional": true
    }
  }
}
```

### OfficeWithLawyers Response (For Lawyer Management)

```json
{
  "data": {
    "id": "43",
    "type": "office",
    "attributes": {
      "name": "Amber Knight Law Office",
      "quote_value": "26.0",
      "number_of_quotes": 668,
      "total_quotes_value": "17368.0",
      "proportional": true,
      "lawyers": [
        {
          "id": 1,
          "user_office_id": 1,
          "email": "joao@example.com",
          "oab": "OAB/PR 12345",
          "name": "João Silva",
          "partnership_type": "socio",
          "partnership_percentage": 60.0,
          "is_administrator": true,
          "entry_date": "2023-01-01",
          "current_compensation": {
            "id": 1,
            "compensation_type": "pro_labore",
            "amount": 5000.0,
            "amount_formatted": "R$ 5.000,00",
            "payment_frequency": "monthly",
            "effective_date": "2024-01-01",
            "end_date": null,
            "notes": "Pro-labore administrativo"
          },
          "all_compensations": [
            {
              "id": 1,
              "compensation_type": "pro_labore",
              "amount": 5000.0,
              "amount_formatted": "R$ 5.000,00",
              "payment_frequency": "monthly",
              "effective_date": "2024-01-01",
              "end_date": null,
              "notes": "Pro-labore administrativo"
            }
          ]
        }
      ]
    }
  }
}
```

## Validation Rules

### Frontend Validation

```javascript
const validateCompensation = (compensation) => {
  const errors = {};

  // Required fields
  if (!compensation.compensation_type) {
    errors.compensation_type = 'Tipo de remuneração é obrigatório';
  }

  if (!compensation.amount || compensation.amount <= 0) {
    errors.amount = 'Valor deve ser maior que zero';
  }

  if (!compensation.effective_date) {
    errors.effective_date = 'Data de início é obrigatória';
  }

  // End date validation
  if (compensation.end_date && compensation.effective_date) {
    if (new Date(compensation.end_date) <= new Date(compensation.effective_date)) {
      errors.end_date = 'Data de fim deve ser posterior à data de início';
    }
  }

  return errors;
};

const validateOffice = (office) => {
  const errors = {};

  // Partnership percentage validation for companies
  if (office.society === 'company') {
    const totalPercentage = office.user_offices_attributes
      .filter(uo => uo.partnership_type === 'socio')
      .reduce((sum, uo) => sum + parseFloat(uo.partnership_percentage || 0), 0);

    if (Math.abs(totalPercentage - 100) > 0.02) {
      errors.partnership_percentage = 'A soma das participações deve ser 100%';
    }
  }

  return errors;
};
```

## Key Changes from Previous Version

### 1. Removed Features
- ❌ `proportional` compensation type (no longer valid)
- ❌ Office-level compensation handling

### 2. New Features
- ✅ `office.proportional` boolean field
- ✅ Nested `compensations_attributes` through `user_offices`
- ✅ Only `pro_labore` and `salary` compensation types
- ✅ Enhanced validation rules

### 3. Migration Notes
```javascript
// OLD structure (deprecated)
const oldCompensation = {
  compensation_type: 'proportional' // ❌ No longer supported
};

// NEW structure
const newOffice = {
  proportional: true, // ✅ Moved to office level
  user_offices_attributes: [
    {
      compensations_attributes: [
        {
          compensation_type: 'pro_labore' // ✅ Only pro_labore or salary
        }
      ]
    }
  ]
};
```

## Testing Examples

### cURL Examples

```bash
# Create office with compensations
curl -X POST "http://localhost:3000/api/v1/offices" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "office": {
      "name": "Test Office",
      "proportional": true,
      "user_offices_attributes": [
        {
          "user_id": 1,
          "partnership_type": "socio",
          "partnership_percentage": 100,
          "compensations_attributes": [
            {
              "compensation_type": "pro_labore",
              "amount": 5000,
              "payment_frequency": "monthly",
              "effective_date": "2024-01-01"
            }
          ]
        }
      ]
    }
  }'
```

This guide should help your frontend team integrate the new compensation structure properly. The key points are using the office-level `proportional` field and nesting compensations through `user_offices_attributes`.