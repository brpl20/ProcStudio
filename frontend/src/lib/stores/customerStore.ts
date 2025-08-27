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
  allCustomers: Customer[];  // All loaded customers
  filteredCustomers: Customer[];  // Filtered customers
  paginatedCustomers: Customer[];  // Current page customers
  currentCustomer: Customer | null;
  isLoading: boolean;
  error: string;
  success: string;
  // Pagination state
  pagination: {
    currentPage: number;
    perPage: number;
    totalPages: number;
    totalRecords: number;
  };
  // Filter state
  filters: {
    search: string;
    status: string;
    capacity: string;
    customerType: string;
  };
}

// Initial state
const initialState: CustomerState = {
  allCustomers: [],
  filteredCustomers: [],
  paginatedCustomers: [],
  currentCustomer: null,
  isLoading: false,
  error: '',
  success: '',
  pagination: {
    currentPage: 1,
    perPage: 50,
    totalPages: 1,
    totalRecords: 0
  },
  filters: {
    search: '',
    status: '',
    capacity: '',
    customerType: ''
  }
};

// Helper functions for filtering
function filterCustomers(customers: Customer[], filters: CustomerState['filters']): Customer[] {
  let filtered = [...customers];

  // Search filter (name, email, CPF, CNPJ)
  if (filters.search && filters.search.trim()) {
    const searchTerm = filters.search.toLowerCase().trim();
    filtered = filtered.filter(customer => {
      const profileCustomer = customer.profile_customer;
      if (!profileCustomer) return false;

      const name = `${profileCustomer.attributes.name || ''} ${profileCustomer.attributes.last_name || ''}`.toLowerCase();
      const email = customer.access_email?.toLowerCase() || '';
      const cpf = profileCustomer.attributes.cpf || '';
      const cnpj = profileCustomer.attributes.cnpj || '';

      return name.includes(searchTerm) || 
             email.includes(searchTerm) || 
             cpf.includes(searchTerm) || 
             cnpj.includes(searchTerm);
    });
  }

  // Status filter
  if (filters.status) {
    filtered = filtered.filter(customer => customer.status === filters.status);
  }

  // Capacity filter
  if (filters.capacity) {
    filtered = filtered.filter(customer => 
      customer.profile_customer?.attributes?.capacity === filters.capacity
    );
  }

  // Customer type filter  
  if (filters.customerType) {
    filtered = filtered.filter(customer => 
      customer.profile_customer?.attributes?.customer_type === filters.customerType
    );
  }

  return filtered;
}

// Helper function for pagination
function paginateCustomers(customers: Customer[], page: number, perPage: number): Customer[] {
  const startIndex = (page - 1) * perPage;
  const endIndex = startIndex + perPage;
  return customers.slice(startIndex, endIndex);
}

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

    // Load all customers (only called once)
    async loadCustomers(): Promise<boolean> {
      update((state) => ({ ...state, isLoading: true, error: '' }));

      // Load all customers from API once
      const response = await api.customers.getCustomers();

      if (response.success) {
        update((state) => {
          // Store all customers
          const allCustomers = response.data;
          
          // Apply filters
          const filtered = filterCustomers(allCustomers, state.filters);
          
          // Calculate pagination
          const totalPages = Math.ceil(filtered.length / state.pagination.perPage);
          const currentPage = Math.min(state.pagination.currentPage, Math.max(1, totalPages));
          
          // Get current page data
          const paginated = paginateCustomers(filtered, currentPage, state.pagination.perPage);
          
          return {
            ...state,
            allCustomers,
            filteredCustomers: filtered,
            paginatedCustomers: paginated,
            isLoading: false,
            pagination: {
              ...state.pagination,
              totalRecords: filtered.length,
              totalPages,
              currentPage
            },
            success: allCustomers.length > 0 ? 'Clientes carregados com sucesso' : '',
            error: ''
          };
        });
        return true;
      } else {
        update((state) =>
          showNotification(
            {
              ...state,
              isLoading: false
            },
            response.message || 'Erro ao carregar clientes',
            true
          )
        );
        return false;
      }
    },

    // Apply filters and pagination (no API call)
    applyFiltersAndPagination(): void {
      update((state) => {
        // Apply filters to all customers
        const filtered = filterCustomers(state.allCustomers, state.filters);
        
        // Calculate pagination
        const totalPages = Math.ceil(filtered.length / state.pagination.perPage);
        const currentPage = Math.min(state.pagination.currentPage, Math.max(1, totalPages));
        
        // Get current page data
        const paginated = paginateCustomers(filtered, currentPage, state.pagination.perPage);
        
        return {
          ...state,
          filteredCustomers: filtered,
          paginatedCustomers: paginated,
          pagination: {
            ...state.pagination,
            totalRecords: filtered.length,
            totalPages,
            currentPage
          }
        };
      });
    },

    // Set search filter (no API call)
    setSearch(term: string): void {
      update((state) => ({
        ...state,
        filters: { ...state.filters, search: term },
        pagination: { ...state.pagination, currentPage: 1 }
      }));
      this.applyFiltersAndPagination();
    },

    // Set filters (no API call)
    setFilters(filters: { status: string; capacity: string; customerType: string }): void {
      update((state) => ({
        ...state,
        filters: { ...state.filters, ...filters },
        pagination: { ...state.pagination, currentPage: 1 }
      }));
      this.applyFiltersAndPagination();
    },

    // Clear all filters (no API call)
    clearFilters(): void {
      update((state) => ({
        ...state,
        filters: {
          search: '',
          status: '',
          capacity: '',
          customerType: ''
        },
        pagination: { ...state.pagination, currentPage: 1 }
      }));
      this.applyFiltersAndPagination();
    },

    // Change page (no API call)
    setPage(page: number): void {
      update((state) => ({
        ...state,
        pagination: { ...state.pagination, currentPage: page }
      }));
      this.applyFiltersAndPagination();
    },

    // Change per page (no API call)
    setPerPage(perPage: number): void {
      update((state) => ({
        ...state,
        pagination: { ...state.pagination, perPage, currentPage: 1 }
      }));
      this.applyFiltersAndPagination();
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

    // Create a new customer (simple)
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
        // Field validation errors exist but are handled by the message

        update((state) =>
          showNotification(
            {
              ...state,
              isLoading: false
            },
            response.message || 'Erro ao criar cliente',
            true
          )
        );
        return false;
      }
    },

    // Create a new profile customer (complete with ProfileCustomer data)
    async addProfileCustomer(profileCustomerData: any): Promise<any> {
      update((state) => ({ ...state, isLoading: true, error: '' }));

      const response = await api.customers.createProfileCustomer(profileCustomerData);

      if (response.success) {
        update((state) =>
          showNotification(
            {
              ...state,
              isLoading: false,
              currentCustomer: response.data
            },
            'Cliente criado com sucesso'
          )
        );
        // Return the created customer data instead of just true
        return response.data;
      } else {
        // Field validation errors exist but are handled by the message

        update((state) =>
          showNotification(
            {
              ...state,
              isLoading: false
            },
            response.message || 'Erro ao criar cliente',
            true
          )
        );
        return null;
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
        // Field validation errors exist but are handled by the message

        update((state) =>
          showNotification(
            {
              ...state,
              isLoading: false
            },
            response.message || 'Erro ao atualizar cliente',
            true
          )
        );
        return false;
      }
    },

    // Update an existing profile customer
    async updateProfileCustomer(id: number, profileCustomerData: any): Promise<boolean> {
      update((state) => ({ ...state, isLoading: true, error: '' }));

      const response = await api.customers.updateProfileCustomer(id, profileCustomerData);

      if (response.success) {
        update((state) =>
          showNotification(
            {
              ...state,
              isLoading: false
            },
            'Cliente atualizado com sucesso'
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
            response.message || 'Erro ao atualizar cliente',
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
