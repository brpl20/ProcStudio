# Draft System Implementation Manual

## Overview

The Draft System provides automatic form data saving to prevent users from losing their work due to browser crashes, accidental navigation, or other interruptions. This manual covers the complete implementation guide for frontend developers.

## Table of Contents

1. [Quick Start](#quick-start)
2. [API Endpoints](#api-endpoints)
3. [Frontend Integration](#frontend-integration)
4. [JavaScript Implementation](#javascript-implementation)
5. [React/Vue/Svelte Examples](#framework-examples)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

## Quick Start

### Basic Implementation

```javascript
// 1. Include the DraftManager class (from frontend_draft_helper.js)
import DraftManager from './services/DraftManager';

// 2. Initialize with your API URL and auth token
const draftManager = new DraftManager(
  'http://api.yourapp.com',
  authToken
);

// 3. Attach to your form
const form = document.getElementById('customer-form');
draftManager.attachToForm(
  form,
  'ProfileCustomer',  // Model name
  '123',              // Record ID
  'profile_form'      // Form type identifier
);
```

## API Endpoints

### 1. Save Draft
```http
POST /api/v1/drafts/save
Content-Type: application/json
Authorization: Bearer {token}

{
  "draftable_type": "ProfileCustomer",
  "draftable_id": "123",
  "form_type": "profile_form",
  "data": {
    "name": "John",
    "email": "john@example.com",
    "addresses_attributes": {
      "0": { "street": "Main St", "number": "123" }
    }
  }
}

Response:
{
  "draft": {
    "id": 45,
    "message": "Draft saved successfully"
  }
}
```

### 2. Get Draft
```http
GET /api/v1/drafts/show?draftable_type=ProfileCustomer&draftable_id=123&form_type=profile_form
Authorization: Bearer {token}

Response:
{
  "draft": {
    "id": 45,
    "data": { ... },
    "expires_at": "2024-09-23T10:30:00Z"
  }
}
```

### 3. List All User Drafts
```http
GET /api/v1/drafts
Authorization: Bearer {token}

Response:
{
  "drafts": [
    {
      "id": 45,
      "draftable_type": "ProfileCustomer",
      "draftable_id": 123,
      "form_type": "profile_form",
      "data": { ... },
      "expires_at": "2024-09-23T10:30:00Z"
    }
  ]
}
```

### 4. Recover Draft
```http
POST /api/v1/drafts/{id}/recover
Authorization: Bearer {token}

Response:
{
  "draft": { ... },
  "message": "Draft recovered successfully"
}
```

### 5. Delete Draft
```http
DELETE /api/v1/drafts/{id}
Authorization: Bearer {token}

Response:
{
  "message": "Draft deleted successfully"
}
```

## Frontend Integration

### HTML Form Setup

```html
<!-- Add data attributes to your form for easy identification -->
<form id="customer-form" 
      data-model="ProfileCustomer" 
      data-record-id="123" 
      data-form-type="profile_form">
  
  <input type="text" name="name" placeholder="Name" />
  <input type="email" name="email" placeholder="Email" />
  
  <!-- Nested attributes for Rails -->
  <div class="address-fields">
    <input type="text" name="addresses_attributes[0][street]" />
    <input type="text" name="addresses_attributes[0][number]" />
  </div>
  
  <button type="submit">Save</button>
</form>
```

### JavaScript Implementation

```javascript
class DraftIntegration {
  constructor() {
    this.apiUrl = process.env.API_URL;
    this.authToken = localStorage.getItem('authToken');
    this.draftManager = new DraftManager(this.apiUrl, this.authToken);
  }

  initializeForm(formId) {
    const form = document.getElementById(formId);
    if (!form) return;

    const model = form.dataset.model;
    const recordId = form.dataset.recordId;
    const formType = form.dataset.formType;

    // Attach draft manager
    this.draftManager.attachToForm(form, model, recordId, formType);

    // Handle successful submission
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      
      try {
        // Submit form data to your backend
        const response = await this.submitForm(form);
        
        if (response.ok) {
          // Clear draft on successful submission
          this.draftManager.setAutoSave(false);
          // Optionally delete the draft
          const draft = await this.draftManager.recoverDraft(model, recordId, formType);
          if (draft) {
            await this.draftManager.deleteDraft(draft.draft.id);
          }
        }
      } catch (error) {
        console.error('Form submission failed:', error);
      }
    });
  }

  async submitForm(form) {
    const formData = new FormData(form);
    const data = Object.fromEntries(formData);
    
    return fetch(`${this.apiUrl}/api/v1/profile_customers/${form.dataset.recordId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.authToken}`
      },
      body: JSON.stringify({ profile_customer: data })
    });
  }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
  const draftIntegration = new DraftIntegration();
  draftIntegration.initializeForm('customer-form');
});
```

## Framework Examples

### React Implementation

```jsx
import React, { useEffect, useRef } from 'react';
import DraftManager from './services/DraftManager';

function CustomerForm({ customerId }) {
  const formRef = useRef(null);
  const draftManagerRef = useRef(null);

  useEffect(() => {
    // Initialize draft manager
    draftManagerRef.current = new DraftManager(
      process.env.REACT_APP_API_URL,
      localStorage.getItem('authToken')
    );

    // Attach to form
    if (formRef.current) {
      draftManagerRef.current.attachToForm(
        formRef.current,
        'ProfileCustomer',
        customerId,
        'profile_form'
      );
    }

    // Cleanup
    return () => {
      if (draftManagerRef.current) {
        draftManagerRef.current.setAutoSave(false);
      }
    };
  }, [customerId]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Disable auto-save during submission
    draftManagerRef.current.setAutoSave(false);
    
    // Your submission logic here
    try {
      const formData = new FormData(formRef.current);
      // ... submit to backend
      
      // Clear draft after successful submission
      // Draft will be automatically cleared by backend
    } catch (error) {
      // Re-enable auto-save if submission fails
      draftManagerRef.current.setAutoSave(true);
    }
  };

  return (
    <form ref={formRef} onSubmit={handleSubmit}>
      <input name="name" placeholder="Name" />
      <input name="email" placeholder="Email" />
      <button type="submit">Save</button>
    </form>
  );
}
```

### Vue 3 Implementation

```vue
<template>
  <form ref="formRef" @submit.prevent="handleSubmit">
    <input v-model="formData.name" name="name" placeholder="Name" />
    <input v-model="formData.email" name="email" placeholder="Email" />
    <button type="submit">Save</button>
  </form>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import DraftManager from './services/DraftManager';

const props = defineProps(['customerId']);
const formRef = ref(null);
const draftManager = ref(null);
const formData = ref({
  name: '',
  email: ''
});

onMounted(() => {
  // Initialize draft manager
  draftManager.value = new DraftManager(
    import.meta.env.VITE_API_URL,
    localStorage.getItem('authToken')
  );

  // Attach to form
  if (formRef.value) {
    draftManager.value.attachToForm(
      formRef.value,
      'ProfileCustomer',
      props.customerId,
      'profile_form'
    );
  }
});

onUnmounted(() => {
  if (draftManager.value) {
    draftManager.value.setAutoSave(false);
  }
});

const handleSubmit = async () => {
  draftManager.value.setAutoSave(false);
  
  try {
    // Submit to backend
    const response = await fetch(`/api/v1/profile_customers/${props.customerId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('authToken')}`
      },
      body: JSON.stringify({ profile_customer: formData.value })
    });
    
    if (response.ok) {
      // Draft will be cleared automatically
      console.log('Form submitted successfully');
    }
  } catch (error) {
    // Re-enable auto-save on error
    draftManager.value.setAutoSave(true);
  }
};
</script>
```

### Svelte Implementation

```svelte
<script>
  import { onMount, onDestroy } from 'svelte';
  import DraftManager from './services/DraftManager';
  
  export let customerId;
  
  let formElement;
  let draftManager;
  let formData = {
    name: '',
    email: ''
  };
  
  onMount(() => {
    draftManager = new DraftManager(
      import.meta.env.VITE_API_URL,
      localStorage.getItem('authToken')
    );
    
    if (formElement) {
      draftManager.attachToForm(
        formElement,
        'ProfileCustomer',
        customerId,
        'profile_form'
      );
    }
  });
  
  onDestroy(() => {
    if (draftManager) {
      draftManager.setAutoSave(false);
    }
  });
  
  async function handleSubmit(event) {
    event.preventDefault();
    draftManager.setAutoSave(false);
    
    try {
      // Submit to backend
      const response = await fetch(`/api/v1/profile_customers/${customerId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('authToken')}`
        },
        body: JSON.stringify({ profile_customer: formData })
      });
      
      if (response.ok) {
        console.log('Form submitted successfully');
      }
    } catch (error) {
      draftManager.setAutoSave(true);
    }
  }
</script>

<form bind:this={formElement} on:submit={handleSubmit}>
  <input bind:value={formData.name} name="name" placeholder="Name" />
  <input bind:value={formData.email} name="email" placeholder="Email" />
  <button type="submit">Save</button>
</form>
```

## Best Practices

### 1. Debounce Configuration

```javascript
// Adjust debounce delay based on form complexity
draftManager.debounceDelay = 1000; // 1 second for simple forms
draftManager.debounceDelay = 3000; // 3 seconds for complex forms
```

### 2. Error Handling

```javascript
// Wrap draft operations in try-catch
try {
  await draftManager.saveDraft(model, id, formType, data);
} catch (error) {
  console.error('Draft save failed:', error);
  // Show user-friendly error message
  showNotification('Unable to save draft. Please try again.', 'warning');
}
```

### 3. Custom Recovery Prompt

```javascript
// Override the default confirmation dialog
draftManager.confirmRecovery = async () => {
  return await showCustomModal({
    title: 'Recover Draft',
    message: 'We found an unsaved draft. Would you like to restore it?',
    buttons: ['Restore', 'Discard']
  }) === 'Restore';
};
```

### 4. Selective Field Saving

```javascript
// Only save specific fields as draft
const formData = draftManager.serializeForm(form);
const draftData = {
  name: formData.name,
  email: formData.email,
  // Exclude sensitive fields like passwords
};
draftManager.autoSave(model, id, formType, draftData);
```

### 5. Multiple Forms on Same Page

```javascript
// Initialize separate managers for each form
const profileManager = new DraftManager(apiUrl, token);
profileManager.attachToForm(profileForm, 'ProfileCustomer', id, 'profile');

const addressManager = new DraftManager(apiUrl, token);
addressManager.attachToForm(addressForm, 'ProfileCustomer', id, 'address');
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Draft Not Saving

**Issue**: Draft auto-save not triggering
```javascript
// Check if auto-save is enabled
console.log('Auto-save enabled:', draftManager.isAutoSaveEnabled);

// Manually trigger save for debugging
draftManager.saveDraft(model, id, formType, data)
  .then(response => console.log('Draft saved:', response))
  .catch(error => console.error('Save failed:', error));
```

#### 2. Draft Not Recovering

**Issue**: Existing draft not showing on form load
```javascript
// Manually check for draft
draftManager.recoverDraft(model, id, formType)
  .then(draft => {
    if (draft) {
      console.log('Draft found:', draft);
      draftManager.populateForm(form, draft.data);
    } else {
      console.log('No draft found');
    }
  });
```

#### 3. Form Data Not Serializing Correctly

**Issue**: Nested attributes not being captured
```javascript
// Debug form serialization
const formData = draftManager.serializeForm(form);
console.log('Serialized data:', JSON.stringify(formData, null, 2));

// For complex forms, manually serialize
const customData = {
  profile: {
    name: form.querySelector('[name="name"]').value,
    addresses: Array.from(form.querySelectorAll('.address')).map(addr => ({
      street: addr.querySelector('[name*="street"]').value,
      number: addr.querySelector('[name*="number"]').value
    }))
  }
};
```

#### 4. Authentication Issues

**Issue**: 401 Unauthorized errors
```javascript
// Update auth token
draftManager.authToken = getNewAuthToken();

// Or reinitialize manager
draftManager = new DraftManager(apiUrl, getNewAuthToken());
```

## Security Considerations

1. **Never save sensitive data** (passwords, credit cards) in drafts
2. **Validate draft data** on recovery before populating forms
3. **Use HTTPS** for all API communications
4. **Implement rate limiting** on draft save endpoints
5. **Set appropriate expiration times** (default: 30 days)

## Performance Tips

1. **Increase debounce delay** for large forms (3-5 seconds)
2. **Compress large JSON data** before sending to API
3. **Use localStorage** for offline draft backup
4. **Implement progressive saving** (only send changed fields)
5. **Clean up expired drafts** regularly

## Support

For additional help or questions:
- Check the API documentation at `/api/docs`
- Review the backend implementation in `app/models/draft.rb`
- Contact the development team

---

Last Updated: December 2024
Version: 1.0.0