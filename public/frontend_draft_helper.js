// Frontend Draft Management Helper
// This file should be integrated into your frontend application

class DraftManager {
  constructor(apiBaseUrl, authToken) {
    this.apiBaseUrl = apiBaseUrl;
    this.authToken = authToken;
    this.debounceTimer = null;
    this.debounceDelay = 2000; // 2 seconds
    this.isAutoSaveEnabled = true;
  }

  // Enable/disable auto-save
  setAutoSave(enabled) {
    this.isAutoSaveEnabled = enabled;
    if (!enabled && this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }
  }

  // Auto-save with debouncing
  autoSave(draftableType, draftableId, formType, formData) {
    if (!this.isAutoSaveEnabled) return;

    // Clear existing timer
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }

    // Set new timer
    this.debounceTimer = setTimeout(() => {
      this.saveDraft(draftableType, draftableId, formType, formData)
        .then(response => {
          console.log('Draft auto-saved:', response);
          this.showNotification('Draft saved', 'success');
        })
        .catch(error => {
          console.error('Failed to auto-save draft:', error);
          this.showNotification('Failed to save draft', 'error');
        });
    }, this.debounceDelay);
  }

  // Save draft immediately
  async saveDraft(draftableType, draftableId, formType, formData) {
    const response = await fetch(`${this.apiBaseUrl}/api/v1/drafts/save`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.authToken}`
      },
      body: JSON.stringify({
        draftable_type: draftableType,
        draftable_id: draftableId,
        form_type: formType,
        data: formData
      })
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return response.json();
  }

  // Recover draft
  async recoverDraft(draftableType, draftableId, formType) {
    const response = await fetch(`${this.apiBaseUrl}/api/v1/drafts/show`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${this.authToken}`
      },
      params: {
        draftable_type: draftableType,
        draftable_id: draftableId,
        form_type: formType
      }
    });

    if (!response.ok) {
      if (response.status === 404) {
        return null; // No draft found
      }
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return response.json();
  }

  // Check for existing draft on form load
  async checkForDraft(draftableType, draftableId, formType) {
    try {
      const draft = await this.recoverDraft(draftableType, draftableId, formType);
      
      if (draft && draft.draft) {
        const shouldRecover = await this.confirmRecovery();
        
        if (shouldRecover) {
          return draft.draft.data;
        } else {
          // Mark draft as recovered so it won't show again
          await this.markDraftRecovered(draft.draft.id);
        }
      }
    } catch (error) {
      console.error('Error checking for draft:', error);
    }
    
    return null;
  }

  // Mark draft as recovered
  async markDraftRecovered(draftId) {
    const response = await fetch(`${this.apiBaseUrl}/api/v1/drafts/${draftId}/recover`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.authToken}`
      }
    });

    return response.json();
  }

  // Delete draft
  async deleteDraft(draftId) {
    const response = await fetch(`${this.apiBaseUrl}/api/v1/drafts/${draftId}`, {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${this.authToken}`
      }
    });

    return response.ok;
  }

  // Show notification (customize based on your UI framework)
  showNotification(message, type) {
    // Example implementation - replace with your notification system
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
      notification.remove();
    }, 3000);
  }

  // Confirm recovery dialog (customize based on your UI framework)
  async confirmRecovery() {
    // Example implementation - replace with your dialog system
    return confirm('A draft was found for this form. Would you like to recover it?');
  }

  // Attach to form
  attachToForm(formElement, draftableType, draftableId, formType) {
    // Check for existing draft on load
    this.checkForDraft(draftableType, draftableId, formType).then(draftData => {
      if (draftData) {
        this.populateForm(formElement, draftData);
      }
    });

    // Listen for form changes
    let formChangeHandler = () => {
      const formData = this.serializeForm(formElement);
      this.autoSave(draftableType, draftableId, formType, formData);
    };

    // Add listeners to all form inputs
    const inputs = formElement.querySelectorAll('input, textarea, select');
    inputs.forEach(input => {
      input.addEventListener('input', formChangeHandler);
      input.addEventListener('change', formChangeHandler);
    });

    // Save draft before page unload
    window.addEventListener('beforeunload', (e) => {
      if (this.debounceTimer) {
        // Force save if there's pending changes
        clearTimeout(this.debounceTimer);
        const formData = this.serializeForm(formElement);
        this.saveDraft(draftableType, draftableId, formType, formData);
      }
    });

    // Clear draft on successful form submission
    formElement.addEventListener('submit', async (e) => {
      // Assuming form submission is handled elsewhere
      // Clear any pending auto-saves
      if (this.debounceTimer) {
        clearTimeout(this.debounceTimer);
      }
    });
  }

  // Serialize form data
  serializeForm(formElement) {
    const formData = new FormData(formElement);
    const data = {};
    
    for (let [key, value] of formData.entries()) {
      // Handle nested attributes (Rails style)
      const keys = key.match(/([^\[\]]+)/g);
      if (keys.length > 1) {
        let current = data;
        for (let i = 0; i < keys.length - 1; i++) {
          if (!current[keys[i]]) {
            current[keys[i]] = {};
          }
          current = current[keys[i]];
        }
        current[keys[keys.length - 1]] = value;
      } else {
        data[key] = value;
      }
    }
    
    return data;
  }

  // Populate form with draft data
  populateForm(formElement, draftData) {
    Object.keys(draftData).forEach(key => {
      const input = formElement.querySelector(`[name="${key}"]`);
      if (input) {
        if (input.type === 'checkbox' || input.type === 'radio') {
          input.checked = draftData[key] === 'true' || draftData[key] === true;
        } else {
          input.value = draftData[key];
        }
      } else {
        // Handle nested attributes
        this.populateNestedFields(formElement, key, draftData[key]);
      }
    });
  }

  // Populate nested fields
  populateNestedFields(formElement, prefix, data) {
    if (typeof data === 'object' && data !== null) {
      Object.keys(data).forEach(key => {
        const fieldName = `${prefix}[${key}]`;
        const input = formElement.querySelector(`[name="${fieldName}"]`);
        if (input) {
          input.value = data[key];
        } else {
          this.populateNestedFields(formElement, fieldName, data[key]);
        }
      });
    }
  }
}

// Usage Example:
/*
// Initialize the draft manager
const draftManager = new DraftManager('http://localhost:3000', 'your-auth-token');

// Attach to a form
const formElement = document.getElementById('customer-profile-form');
draftManager.attachToForm(
  formElement,
  'ProfileCustomer',
  '123', // profile customer ID
  'profile_form'
);

// Or manually trigger auto-save
formElement.addEventListener('input', () => {
  const formData = draftManager.serializeForm(formElement);
  draftManager.autoSave('ProfileCustomer', '123', 'profile_form', formData);
});

// Disable auto-save temporarily
draftManager.setAutoSave(false);

// Re-enable auto-save
draftManager.setAutoSave(true);
*/

export default DraftManager;