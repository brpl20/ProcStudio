# Frontend Integration Guide for Work and Customer Endpoints

## Overview
This guide provides comprehensive instructions for integrating the Work, Customer, and ProfileCustomer endpoints from the Rails API into a Svelte frontend application. The API follows RESTful conventions with JWT authentication for both admin (backoffice) and customer authentication.

## Authentication Requirements

### Admin/Backoffice Authentication
- **Endpoint**: Uses JWT tokens in Authorization header
- **Format**: `Authorization: Bearer <jwt_token>`
- **Required for**: All `/api/v1/works`, `/api/v1/customers`, `/api/v1/profile_customers` endpoints
- **Controller**: Inherits from `BackofficeController` which includes JWT authentication

### Customer Authentication
- **Login Endpoint**: `POST /api/v1/customer/login`
- **Logout Endpoint**: `DELETE /api/v1/customer/logout`
- **Password Reset**: `POST /api/v1/customer/password`
- **Email Confirmation**: `GET /api/v1/customer/confirm?confirmation_token=<token>`
- **Response**: Returns JWT token and full_name

## Work Endpoints

### Model Structure
```javascript
// Work model attributes
{
  id: number,
  procedure: string, // 'administrative', 'judicial', 'extrajudicial'
  status: string, // 'in_progress', 'paused', 'completed', 'archived'
  law_area_id: number,
  number: number,
  folder: string,
  note: string,
  extra_pending_document: string,
  
  // Financial fields
  compensations_five_years: boolean,
  compensations_service: boolean,
  lawsuit: boolean,
  gain_projection: string,
  
  // Team assignments
  physical_lawyer: number,
  responsible_lawyer: number,
  partner_lawyer: number,
  intern: number,
  bachelor: number,
  
  // Relationships
  profile_customers: ProfileCustomer[],
  user_profiles: UserProfile[],
  documents: Document[],
  pending_documents: PendingDocument[],
  powers: Power[],
  recommendations: Recommendation[],
  jobs: Job[],
  work_events: WorkEvent[],
  honorary: Honorary,
  
  // Timestamps
  created_at: string,
  updated_at: string,
  deleted_at: string | null
}
```

### 1. List Works
```javascript
// GET /api/v1/works
// Query parameters:
// - customer_id: Filter by customer
// - deleted: Include deleted records
// - limit: Limit number of results

async function fetchWorks(filters = {}) {
  const params = new URLSearchParams(filters);
  const response = await fetch(`${API_BASE}/api/v1/works?${params}`, {
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    }
  });
  
  const data = await response.json();
  // Response includes meta.total_count for pagination
  return data;
}
```

### 2. Get Single Work
```javascript
// GET /api/v1/works/:id
async function fetchWork(id) {
  const response = await fetch(`${API_BASE}/api/v1/works/${id}`, {
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    }
  });
  
  return await response.json();
}
```

### 3. Create Work
```javascript
// POST /api/v1/works
async function createWork(workData) {
  const payload = {
    work: {
      procedure: workData.procedure,
      law_area_id: workData.lawAreaId,
      number: workData.number,
      folder: workData.folder,
      note: workData.note,
      status: workData.status || 'in_progress',
      
      // Nested attributes
      documents_attributes: workData.documents || [],
      pending_documents_attributes: workData.pendingDocuments || [],
      recommendations_attributes: workData.recommendations || [],
      honorary_attributes: workData.honorary || {},
      
      // Relationship IDs
      power_ids: workData.powerIds || [],
      profile_customer_ids: workData.profileCustomerIds || [],
      user_profile_ids: workData.userProfileIds || [],
      office_ids: workData.officeIds || []
    }
  };
  
  const response = await fetch(`${API_BASE}/api/v1/works`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.errors[0].code);
  }
  
  return await response.json();
}
```

### 4. Update Work
```javascript
// PATCH /api/v1/works/:id
async function updateWork(id, updates) {
  const payload = {
    work: updates,
    regenerate_documents: false // Set to true to regenerate documents
  };
  
  const response = await fetch(`${API_BASE}/api/v1/works/${id}`, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  });
  
  return await response.json();
}
```

### 5. Delete/Restore Work
```javascript
// DELETE /api/v1/works/:id
async function deleteWork(id, permanently = false) {
  const params = permanently ? '?destroy_fully=true' : '';
  
  await fetch(`${API_BASE}/api/v1/works/${id}${params}`, {
    method: 'DELETE',
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`
    }
  });
}

// POST /api/v1/works/:id/restore
async function restoreWork(id) {
  const response = await fetch(`${API_BASE}/api/v1/works/${id}/restore`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`
    }
  });
  
  return await response.json();
}
```

### 6. Convert Documents to PDF
```javascript
// POST /api/v1/works/:id/convert_documents_to_pdf
async function convertDocumentsToPdf(workId, documentIds) {
  const response = await fetch(`${API_BASE}/api/v1/works/${workId}/convert_documents_to_pdf`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      approved_documents: documentIds
    })
  });
  
  return await response.json();
}
```

## Customer Endpoints

### Model Structure
```javascript
// Customer model attributes
{
  id: number,
  email: string,
  status: string, // 'active', 'inactive', 'deceased'
  confirmed_at: string | null,
  profile_customer: ProfileCustomer,
  
  // Timestamps
  created_at: string,
  updated_at: string,
  deleted_at: string | null
}
```

### 1. List Customers
```javascript
// GET /api/v1/customers
async function fetchCustomers(filters = {}) {
  const params = new URLSearchParams(filters);
  const response = await fetch(`${API_BASE}/api/v1/customers?${params}`, {
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    }
  });
  
  return await response.json();
}
```

### 2. Get Single Customer
```javascript
// GET /api/v1/customers/:id
async function fetchCustomer(id) {
  const response = await fetch(`${API_BASE}/api/v1/customers/${id}`, {
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    }
  });
  
  return await response.json();
}
```

### 3. Create Customer
```javascript
// POST /api/v1/customers
async function createCustomer(customerData) {
  const payload = {
    customer: {
      email: customerData.email,
      access_email: customerData.accessEmail || customerData.email,
      password: customerData.password,
      password_confirmation: customerData.passwordConfirmation,
      status: customerData.status || 'active'
    }
  };
  
  const response = await fetch(`${API_BASE}/api/v1/customers`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.errors[0].code);
  }
  
  return await response.json();
}
```

### 4. Update Customer
```javascript
// PATCH /api/v1/customers/:id
async function updateCustomer(id, updates) {
  const payload = {
    customer: updates
  };
  
  const response = await fetch(`${API_BASE}/api/v1/customers/${id}`, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  });
  
  return await response.json();
}
```

### 5. Resend Confirmation Email
```javascript
// POST /api/v1/customers/:id/resend_confirmation
async function resendConfirmation(customerId) {
  await fetch(`${API_BASE}/api/v1/customers/${customerId}/resend_confirmation`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`
    }
  });
}
```

## ProfileCustomer Endpoints

### Model Structure
```javascript
// ProfileCustomer model attributes
{
  id: number,
  customer_id: number,
  customer_type: string, // 'physical_person', 'legal_person', 'representative', 'counter'
  name: string,
  last_name: string,
  status: string, // 'active', 'inactive', 'deceased'
  
  // Personal information
  cpf: string,
  cnpj: string,
  rg: string,
  birth: string,
  gender: string, // 'male', 'female', 'other'
  nationality: string, // 'brazilian', 'foreigner'
  civil_status: string, // 'single', 'married', 'divorced', 'widower', 'union'
  capacity: string, // 'able', 'relatively', 'unable'
  profession: string,
  mother_name: string,
  
  // Professional information
  company: string,
  accountant_id: number,
  
  // Social security
  number_benefit: string,
  nit: string,
  inss_password: string,
  
  // Relationships
  customer: Customer,
  addresses: Address[],
  phones: Phone[],
  emails: Email[],
  bank_accounts: BankAccount[],
  customer_files: CustomerFile[],
  
  // Timestamps
  created_at: string,
  updated_at: string,
  deleted_at: string | null
}
```

### 1. List ProfileCustomers
```javascript
// GET /api/v1/profile_customers
async function fetchProfileCustomers(filters = {}) {
  const params = new URLSearchParams(filters);
  const response = await fetch(`${API_BASE}/api/v1/profile_customers?${params}`, {
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    }
  });
  
  return await response.json();
}
```

### 2. Get Single ProfileCustomer
```javascript
// GET /api/v1/profile_customers/:id
async function fetchProfileCustomer(id, includeDeleted = false) {
  const params = includeDeleted ? '?include_deleted=true' : '';
  
  const response = await fetch(`${API_BASE}/api/v1/profile_customers/${id}${params}`, {
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    }
  });
  
  return await response.json();
}
```

### 3. Create ProfileCustomer
```javascript
// POST /api/v1/profile_customers
async function createProfileCustomer(profileData) {
  const payload = {
    profile_customer: {
      customer_type: profileData.customerType,
      name: profileData.name,
      last_name: profileData.lastName,
      status: profileData.status || 'active',
      customer_id: profileData.customerId,
      
      // Personal information
      cpf: profileData.cpf,
      cnpj: profileData.cnpj,
      rg: profileData.rg,
      birth: profileData.birth,
      gender: profileData.gender,
      nationality: profileData.nationality,
      civil_status: profileData.civilStatus,
      capacity: profileData.capacity,
      profession: profileData.profession,
      mother_name: profileData.motherName,
      
      // Nested attributes
      addresses_attributes: profileData.addresses || [],
      bank_accounts_attributes: profileData.bankAccounts || [],
      customer_attributes: profileData.customer || {},
      phones_attributes: profileData.phones || [],
      emails_attributes: profileData.emails || [],
      customer_files_attributes: profileData.customerFiles || []
    },
    issue_documents: false // Set to true to generate documents
  };
  
  const response = await fetch(`${API_BASE}/api/v1/profile_customers`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.errors[0].code);
  }
  
  return await response.json();
}
```

### 4. Update ProfileCustomer
```javascript
// PATCH /api/v1/profile_customers/:id
async function updateProfileCustomer(id, updates) {
  const payload = {
    profile_customer: updates,
    regenerate_documents: false // Set to true to regenerate documents
  };
  
  const response = await fetch(`${API_BASE}/api/v1/profile_customers/${id}`, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  });
  
  return await response.json();
}
```

### 5. Delete/Restore ProfileCustomer
```javascript
// DELETE /api/v1/profile_customers/:id
async function deleteProfileCustomer(id, permanently = false) {
  const params = permanently ? '?destroy_fully=true' : '';
  
  await fetch(`${API_BASE}/api/v1/profile_customers/${id}${params}`, {
    method: 'DELETE',
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`
    }
  });
}

// POST /api/v1/profile_customers/:id/restore
async function restoreProfileCustomer(id) {
  const response = await fetch(`${API_BASE}/api/v1/profile_customers/${id}/restore`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`
    }
  });
  
  return await response.json();
}
```

## Customer Portal Endpoints

### Customer Authentication
```javascript
// POST /api/v1/customer/login
async function customerLogin(email, password) {
  const response = await fetch(`${API_BASE}/api/v1/customer/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      auth: { email, password }
    })
  });
  
  if (!response.ok) {
    throw new Error('Invalid credentials');
  }
  
  const data = await response.json();
  // Store token and full_name
  localStorage.setItem('customerToken', data.token);
  localStorage.setItem('customerName', data.full_name);
  
  return data;
}

// DELETE /api/v1/customer/logout
async function customerLogout() {
  const token = localStorage.getItem('customerToken');
  
  await fetch(`${API_BASE}/api/v1/customer/logout`, {
    method: 'DELETE',
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  localStorage.removeItem('customerToken');
  localStorage.removeItem('customerName');
}
```

### Customer Self-Service
```javascript
// GET /api/v1/customer/customers/:id
async function getCustomerProfile(customerId) {
  const token = localStorage.getItem('customerToken');
  
  const response = await fetch(`${API_BASE}/api/v1/customer/customers/${customerId}`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return await response.json();
}

// PATCH /api/v1/customer/customers/:id
async function updateCustomerProfile(customerId, updates) {
  const token = localStorage.getItem('customerToken');
  
  const response = await fetch(`${API_BASE}/api/v1/customer/customers/${customerId}`, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ customer: updates })
  });
  
  return await response.json();
}

// GET /api/v1/customer/works
async function getCustomerWorks() {
  const token = localStorage.getItem('customerToken');
  
  const response = await fetch(`${API_BASE}/api/v1/customer/works`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return await response.json();
}

// GET /api/v1/customer/works/:id
async function getCustomerWork(workId) {
  const token = localStorage.getItem('customerToken');
  
  const response = await fetch(`${API_BASE}/api/v1/customer/works/${workId}`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return await response.json();
}
```

## Error Handling

### Common Error Responses
```javascript
// 400 Bad Request
{
  errors: [{ code: ["Error message"] }]
}

// 401 Unauthorized
{
  error: "Unauthorized access message"
}

// 404 Not Found
{
  error: "Resource not found"
}

// 422 Unprocessable Entity
{
  success: false,
  message: "Validation error message"
}
```

### Error Handling Pattern
```javascript
async function apiRequest(url, options = {}) {
  try {
    const response = await fetch(url, {
      ...options,
      headers: {
        'Authorization': `Bearer ${getAuthToken()}`,
        'Content-Type': 'application/json',
        ...options.headers
      }
    });
    
    if (!response.ok) {
      const error = await response.json();
      
      switch (response.status) {
        case 401:
          // Handle unauthorized - redirect to login
          redirectToLogin();
          break;
        case 404:
          // Handle not found
          showNotification('Resource not found', 'error');
          break;
        case 400:
        case 422:
          // Handle validation errors
          const message = error.errors?.[0]?.code || error.message || 'Validation error';
          showNotification(message, 'error');
          break;
        default:
          throw new Error('An unexpected error occurred');
      }
      
      throw error;
    }
    
    return await response.json();
  } catch (error) {
    console.error('API Request failed:', error);
    throw error;
  }
}
```

## Pagination and Filtering

### Work Filters
- `customer_id`: Filter by specific customer
- `deleted`: Include soft-deleted records
- `limit`: Limit number of results

### Customer/ProfileCustomer Filters
- `deleted`: Include soft-deleted records

### Pagination Response Format
```javascript
{
  data: [...], // Array of resources
  meta: {
    total_count: 100 // Total number of records
  }
}
```

## Nested Attributes

### Creating/Updating with Nested Attributes
When creating or updating resources with relationships, use the `_attributes` suffix:

```javascript
// Example: Creating a ProfileCustomer with addresses and phones
{
  profile_customer: {
    name: "John Doe",
    addresses_attributes: [
      {
        street: "123 Main St",
        city: "New York",
        state: "NY",
        zip_code: "10001"
      }
    ],
    phones_attributes: [
      {
        phone_number: "+1234567890"
      }
    ]
  }
}
```

### Updating Nested Attributes
Include the `id` field to update existing nested records:

```javascript
{
  profile_customer: {
    addresses_attributes: [
      {
        id: 123, // Existing address ID
        street: "456 Updated St"
      }
    ]
  }
}
```

## Soft Delete Implementation

### Soft Delete Behavior
- Regular DELETE removes record (soft delete)
- Records remain in database with `deleted_at` timestamp
- Use `?destroy_fully=true` to permanently delete
- Use `?deleted=true` in index endpoints to include deleted records
- Use POST `/:id/restore` to restore soft-deleted records

### Example Implementation
```javascript
// Soft delete (can be restored)
await deleteWork(workId, false);

// Permanent delete (cannot be restored)
await deleteWork(workId, true);

// Restore soft-deleted record
await restoreWork(workId);

// Fetch including deleted records
await fetchWorks({ deleted: true });
```

## Best Practices

### 1. Token Management
```javascript
// Store tokens securely
class TokenManager {
  static setToken(token) {
    localStorage.setItem('authToken', token);
  }
  
  static getToken() {
    return localStorage.getItem('authToken');
  }
  
  static clearToken() {
    localStorage.removeItem('authToken');
  }
  
  static isAuthenticated() {
    return !!this.getToken();
  }
}
```

### 2. API Client Wrapper
```javascript
class ApiClient {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
  }
  
  async request(endpoint, options = {}) {
    const url = `${this.baseUrl}${endpoint}`;
    const config = {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      }
    };
    
    // Add auth token if available
    const token = TokenManager.getToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    const response = await fetch(url, config);
    
    if (!response.ok) {
      await this.handleError(response);
    }
    
    return await response.json();
  }
  
  async handleError(response) {
    const error = await response.json();
    
    if (response.status === 401) {
      TokenManager.clearToken();
      // Redirect to login
      window.location.href = '/login';
    }
    
    throw new ApiError(response.status, error);
  }
}

// Usage
const api = new ApiClient('https://api.example.com');
const works = await api.request('/api/v1/works');
```

### 3. State Management (Svelte Store Example)
```javascript
// stores/works.js
import { writable, derived } from 'svelte/store';

function createWorksStore() {
  const { subscribe, set, update } = writable({
    items: [],
    loading: false,
    error: null
  });
  
  return {
    subscribe,
    
    async fetchWorks(filters = {}) {
      update(state => ({ ...state, loading: true, error: null }));
      
      try {
        const data = await api.request('/api/v1/works', {
          params: filters
        });
        
        set({
          items: data.data,
          loading: false,
          error: null,
          totalCount: data.meta.total_count
        });
      } catch (error) {
        update(state => ({
          ...state,
          loading: false,
          error: error.message
        }));
      }
    },
    
    async createWork(workData) {
      try {
        const newWork = await api.request('/api/v1/works', {
          method: 'POST',
          body: JSON.stringify({ work: workData })
        });
        
        update(state => ({
          ...state,
          items: [...state.items, newWork.data]
        }));
        
        return newWork.data;
      } catch (error) {
        update(state => ({ ...state, error: error.message }));
        throw error;
      }
    }
  };
}

export const worksStore = createWorksStore();
```

### 4. Form Validation
```javascript
// Validation helper for ProfileCustomer
function validateProfileCustomer(data) {
  const errors = {};
  
  if (!data.name) {
    errors.name = 'Name is required';
  }
  
  if (data.customerType === 'physical_person') {
    if (!data.cpf) {
      errors.cpf = 'CPF is required for physical person';
    }
    // CPF validation logic
  } else if (data.customerType === 'legal_person') {
    if (!data.cnpj) {
      errors.cnpj = 'CNPJ is required for legal person';
    }
    // CNPJ validation logic
  }
  
  return {
    isValid: Object.keys(errors).length === 0,
    errors
  };
}
```

## Testing Recommendations

### 1. Mock API Responses
```javascript
// __mocks__/api.js
export const mockWorks = [
  {
    id: 1,
    procedure: 'administrative',
    status: 'in_progress',
    law_area_id: 1,
    // ... other fields
  }
];

export const mockApiClient = {
  request: jest.fn((endpoint) => {
    if (endpoint === '/api/v1/works') {
      return Promise.resolve({ data: mockWorks });
    }
    // ... other endpoints
  })
};
```

### 2. Component Testing
```javascript
// WorksList.test.js
import { render, waitFor } from '@testing-library/svelte';
import WorksList from './WorksList.svelte';
import { mockApiClient } from './__mocks__/api';

test('renders works list', async () => {
  const { getByText } = render(WorksList, {
    props: { apiClient: mockApiClient }
  });
  
  await waitFor(() => {
    expect(getByText('Administrative')).toBeInTheDocument();
  });
});
```

## Security Considerations

1. **Always use HTTPS** in production
2. **Store tokens securely** (consider using httpOnly cookies for enhanced security)
3. **Implement token refresh** mechanism for long-lived sessions
4. **Validate all inputs** on the frontend before sending to API
5. **Handle sensitive data carefully** (CPF, CNPJ, personal information)
6. **Implement rate limiting** on the frontend to prevent API abuse
7. **Use Content Security Policy** headers
8. **Sanitize user inputs** to prevent XSS attacks

## Troubleshooting

### Common Issues

1. **401 Unauthorized**
   - Check if token is present and valid
   - Verify token is being sent in Authorization header
   - Check if user has required permissions

2. **422 Unprocessable Entity**
   - Check validation errors in response
   - Verify all required fields are present
   - Check data types match API expectations

3. **CORS Issues**
   - Ensure API allows frontend origin
   - Check if credentials are being sent properly
   - Verify headers are correctly configured

4. **Nested Attributes Not Saving**
   - Ensure using `_attributes` suffix
   - Include `id` field when updating existing nested records
   - Check if parent model accepts nested attributes

## Additional Resources

- [Rails API Documentation](https://api.rubyonrails.org/)
- [JWT.io](https://jwt.io/) - JWT token debugging
- [Svelte Documentation](https://svelte.dev/docs)
- [SvelteKit Documentation](https://kit.svelte.dev/docs) - For SSR/routing

## Contact

For API-specific questions or issues, contact the backend development team.
For integration support, refer to the project's technical documentation or create an issue in the project repository.