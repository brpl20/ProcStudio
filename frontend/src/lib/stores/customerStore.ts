// stores/customerStore.ts
import { writable, derived } from 'svelte/store';
import api from '../api'; // Import your API singleton
import type {
  Customer,
  CreateCustomerRequest,
  UpdateCustomerRequest
} from '../api/types/customer.types';

// Define store types
export interface CustomerState {
  customers: Customer[];
  currentCustomer: Customer | null;
  isLoading: boolean;
  error: string;
  success: string;
}

// Initial state
const initialState: CustomerState = {
  customers: [],
  currentCustomer: null,
  isLoading: false,
  error: '',
  success: ''
};

// Create the store
function createCustomerStore() {
  const { subscribe, set, update } = writable<CustomerState>(initialState);

  // Helper for notifications
  function showNotification(state: CustomerState, message: string, isError = false) {
    const updatedState = {
      ...state,
      success: isError ? '' : message,
      error: isError ? message : ''
    };

    // Clear notification after timeout
    setTimeout(
      () => {
        update((state) => ({
          ...state,
          success: isError ? state.success : '',
          error: isError ? '' : state.error
        }));
      },
      isError ? 5000 : 3000
    );

    return updatedState;
  }

  return {
    subscribe,

    // Load all customers
    async loadCustomers(filters?: { deleted?: boolean }): Promise<boolean> {
      update((state) => ({ ...state, isLoading: true, error: '' }));

      // Use the api.customers service that's already initialized
      const response = await api.customers.getCustomers(filters);

      if (response.success) {
        update((state) =>
          showNotification(
            {
              ...state,
              customers: response.data,
              isLoading: false
            },
            'Clientes carregados com sucesso'
          )
        );
        return true;
      } else {
        update((state) =>
          showNotification(
            {
              ...state,
              isLoading: false
            },
            response.message,
            true
          )
        );
        return false;
      }
    },

    // Get a single customer
    async loadCustomer(id: number): Promise<boolean> {
      update((state) => ({ ...state, isLoading: true, error: '' }));

      const response = await api.customers.getCustomer(id);

      if (response.success) {
        update((state) => ({
          ...state,
          currentCustomer: response.data,
          isLoading: false
        }));
        return true;
      } else {
        update((state) =>
          showNotification(
            {
              ...state,
              isLoading: false
            },
            response.message,
            true
          )
        );
        return false;
      }
    },

    // Create a new customer
    async addCustomer(customerData: CreateCustomerRequest): Promise<boolean> {
      update((state) => ({ ...state, isLoading: true, error: '' }));

      const response = await api.customers.createCustomer(customerData);

      if (response.success) {
        update((state) =>
          showNotification(
            {
              ...state,
              customers: [...state.customers, response.data],
              isLoading: false
            },
            'Cliente criado com sucesso'
          )
        );
        return true;
      } else {
        update((state) =>
          showNotification(
            {
              ...state,
              isLoading: false
            },
            response.message,
            true
          )
        );
        return false;
      }
    },

    // Update an existing customer
    async updateCustomer(id: number, customerData: UpdateCustomerRequest): Promise<boolean> {
      update((state) => ({ ...state, isLoading: true, error: '' }));

      const response = await api.customers.updateCustomer(id, customerData);

      if (response.success) {
        update((state) => {
          // Update in the customers array
          const updatedCustomers = state.customers.map((customer) =>
            customer.id === id ? { ...customer, ...response.data } : customer
          );

          // Update current customer if it's the one being edited
          const updatedCurrentCustomer =
            state.currentCustomer?.id === id
              ? { ...state.currentCustomer, ...response.data }
              : state.currentCustomer;

          return showNotification(
            {
              ...state,
              customers: updatedCustomers,
              currentCustomer: updatedCurrentCustomer,
              isLoading: false
            },
            'Cliente atualizado com sucesso'
          );
        });
        return true;
      } else {
        update((state) =>
          showNotification(
            {
              ...state,
              isLoading: false
            },
            response.message,
            true
          )
        );
        return false;
      }
    },

    // Delete a customer
    async deleteCustomer(id: number): Promise<boolean> {
      update((state) => ({ ...state, isLoading: true, error: '' }));

      const response = await api.customers.deleteCustomer(id);

      if (response.success) {
        update((state) => {
          // Remove from customers array
          const filteredCustomers = state.customers.filter((customer) => customer.id !== id);

          // Clear current customer if it's the one being deleted
          const updatedCurrentCustomer =
            state.currentCustomer?.id === id ? null : state.currentCustomer;

          return showNotification(
            {
              ...state,
              customers: filteredCustomers,
              currentCustomer: updatedCurrentCustomer,
              isLoading: false
            },
            'Cliente excluído com sucesso'
          );
        });
        return true;
      } else {
        update((state) =>
          showNotification(
            {
              ...state,
              isLoading: false
            },
            response.message,
            true
          )
        );
        return false;
      }
    },

    // Resend confirmation email
    async resendConfirmation(id: number): Promise<boolean> {
      update((state) => ({ ...state, isLoading: true, error: '' }));

      const response = await api.customers.resendConfirmation(id);

      if (response.success) {
        update((state) =>
          showNotification(
            {
              ...state,
              isLoading: false
            },
            'Email de confirmação reenviado com sucesso'
          )
        );
        return true;
      } else {
        update((state) =>
          showNotification(
            {
              ...state,
              isLoading: false
            },
            response.message,
            true
          )
        );
        return false;
      }
    },

    // Update just the status
    async updateStatus(id: number, status: string): Promise<boolean> {
      return this.updateCustomer(id, { status } as UpdateCustomerRequest);
    },

    // Reset the store
    reset() {
      set(initialState);
    }
  };
}

// Create and export the store
export const customerStore = createCustomerStore();

// Export derived stores for easy access to specific parts of state
export const customers = derived(
  customerStore, 
  ($store: CustomerState) => $store.customers
);

export const activeCustomers = derived(
  customerStore, 
  ($store: CustomerState) => $store.customers.filter((c) => c.status === 'active')
);

export const inactiveCustomers = derived(
  customerStore, 
  ($store: CustomerState) => $store.customers.filter((c) => c.status === 'inactive')
);

export const isLoading = derived(
  customerStore, 
  ($store: CustomerState) => $store.isLoading
);

export const error = derived(
  customerStore, 
  ($store: CustomerState) => $store.error
);

export const success = derived(
  customerStore, 
  ($store: CustomerState) => $store.success
);

export const currentCustomer = derived(
  customerStore, 
  ($store: CustomerState) => $store.currentCustomer
);
