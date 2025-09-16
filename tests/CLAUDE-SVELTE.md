# Svelte Testing Guidelines

## Stack & Version
- Svelte 5
- TypeScript

## Testing Tools
- **Mocha**: JavaScript test framework (if using Node.js testing)
- **Vitest**: Fast Vite-native testing framework
- **Testing Library**: For component testing with user-centric approach
- **Svelte Testing Library**: Specific adaptations for Svelte components
- **Playwright/Cypress**: For end-to-end testing
- **Jest**: Alternative testing framework

## Component Testing

### Basic Component Tests
```javascript
// Button.test.js
import { render, fireEvent } from '@testing-library/svelte';
import Button from './Button.svelte';

describe('Button Component', () => {
  it('renders with correct text', () => {
    const { getByText } = render(Button, { props: { text: 'Click me' } });
    expect(getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const mockClick = vi.fn();
    const { getByRole } = render(Button, {
      props: {
        text: 'Click me',
        onClick: mockClick
      }
    });

    await fireEvent.click(getByRole('button'));
    expect(mockClick).toHaveBeenCalledTimes(1);
  });

  it('applies custom class when provided', () => {
    const { getByRole } = render(Button, {
      props: {
        text: 'Styled button',
        className: 'custom-class'
      }
    });

    expect(getByRole('button')).toHaveClass('custom-class');
  });
});
```

### Store Testing
```javascript
// userStore.test.js
import { userStore } from './userStore';
import { get } from 'svelte/store';

describe('User Store', () => {
  afterEach(() => {
    // Reset store to initial state
    userStore.reset();
  });

  it('starts with initial empty state', () => {
    expect(get(userStore).user).toBeNull();
    expect(get(userStore).isLoading).toBe(false);
    expect(get(userStore).error).toBeNull();
  });

  it('updates state when user logs in', async () => {
    const mockUser = { id: 1, name: 'John' };

    await userStore.login('john@example.com', 'password');

    expect(get(userStore).user).toEqual(mockUser);
    expect(get(userStore).isLoading).toBe(false);
  });

  it('handles login failure correctly', async () => {
    // Mock API to fail
    vi.spyOn(global, 'fetch').mockImplementationOnce(() =>
      Promise.reject(new Error('Network error'))
    );

    await userStore.login('bad@example.com', 'wrong');

    expect(get(userStore).user).toBeNull();
    expect(get(userStore).error).toEqual('Network error');
  });
});
```

### Advanced Component Testing

#### Testing Props and Events
```javascript
// CustomerCard.test.js
import { render, fireEvent } from '@testing-library/svelte';
import CustomerCard from './CustomerCard.svelte';

describe('CustomerCard Component', () => {
  const mockCustomer = {
    id: 1,
    name: 'John Doe',
    email: 'john@example.com',
    status: 'active'
  };

  it('displays customer information', () => {
    const { getByText } = render(CustomerCard, {
      props: { customer: mockCustomer }
    });

    expect(getByText('John Doe')).toBeInTheDocument();
    expect(getByText('john@example.com')).toBeInTheDocument();
    expect(getByText('active')).toBeInTheDocument();
  });

  it('emits edit event when edit button clicked', async () => {
    const component = render(CustomerCard, {
      props: { customer: mockCustomer }
    });

    const editButton = component.getByRole('button', { name: /edit/i });
    await fireEvent.click(editButton);

    // Check if event was dispatched
    expect(component.component.$capture_state().editClicked).toBe(true);
  });

  it('applies correct CSS class based on status', () => {
    const { container } = render(CustomerCard, {
      props: { customer: { ...mockCustomer, status: 'inactive' } }
    });

    expect(container.firstChild).toHaveClass('customer-card--inactive');
  });
});
```

#### Testing Reactive Statements
```javascript
// Counter.test.js
import { render, fireEvent } from '@testing-library/svelte';
import Counter from './Counter.svelte';

describe('Counter Component', () => {
  it('updates doubled value when count changes', async () => {
    const { getByText, getByRole } = render(Counter);

    const incrementButton = getByRole('button', { name: /increment/i });
    await fireEvent.click(incrementButton);

    expect(getByText('Count: 1')).toBeInTheDocument();
    expect(getByText('Doubled: 2')).toBeInTheDocument();
  });

  it('shows warning when count exceeds threshold', async () => {
    const { getByText, getByRole } = render(Counter, {
      props: { threshold: 3 }
    });

    const incrementButton = getByRole('button', { name: /increment/i });
    
    // Click 4 times to exceed threshold
    for (let i = 0; i < 4; i++) {
      await fireEvent.click(incrementButton);
    }

    expect(getByText('Warning: Count exceeded threshold!')).toBeInTheDocument();
  });
});
```

#### Testing Slots and Context
```javascript
// Modal.test.js
import { render } from '@testing-library/svelte';
import Modal from './Modal.svelte';
import TestComponent from './TestComponent.svelte'; // Contains Modal with content

describe('Modal Component', () => {
  it('renders slot content', () => {
    const { getByText } = render(TestComponent);
    expect(getByText('Modal Content')).toBeInTheDocument();
  });

  it('provides correct context to children', () => {
    const { getByTestId } = render(TestComponent);
    const childComponent = getByTestId('modal-child');
    
    // Verify context was passed correctly
    expect(childComponent).toHaveAttribute('data-modal-open', 'true');
  });
});
```

### API Service Testing

#### Mocking API Calls
```javascript
// api.test.js
import { vi } from 'vitest';
import { customerApi } from './api';

describe('Customer API', () => {
  beforeEach(() => {
    global.fetch = vi.fn();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('fetches customers successfully', async () => {
    const mockCustomers = [
      { id: 1, name: 'John Doe' },
      { id: 2, name: 'Jane Smith' }
    ];

    global.fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({ data: mockCustomers })
    });

    const result = await customerApi.getCustomers();
    
    expect(global.fetch).toHaveBeenCalledWith('/api/v1/customers');
    expect(result).toEqual(mockCustomers);
  });

  it('handles API errors gracefully', async () => {
    global.fetch.mockRejectedValueOnce(new Error('Network error'));

    await expect(customerApi.getCustomers()).rejects.toThrow('Network error');
  });

  it('sends correct data for customer creation', async () => {
    const newCustomer = { name: 'Bob Wilson', email: 'bob@example.com' };
    
    global.fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({ data: { id: 3, ...newCustomer } })
    });

    await customerApi.createCustomer(newCustomer);

    expect(global.fetch).toHaveBeenCalledWith('/api/v1/customers', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newCustomer)
    });
  });
});
```

### Form Testing

#### Testing Form Validation
```javascript
// CustomerForm.test.js
import { render, fireEvent } from '@testing-library/svelte';
import CustomerForm from './CustomerForm.svelte';

describe('CustomerForm Component', () => {
  it('validates required fields', async () => {
    const { getByRole, getByText } = render(CustomerForm);

    const submitButton = getByRole('button', { name: /submit/i });
    await fireEvent.click(submitButton);

    expect(getByText('Name is required')).toBeInTheDocument();
    expect(getByText('Email is required')).toBeInTheDocument();
  });

  it('validates email format', async () => {
    const { getByLabelText, getByRole, getByText } = render(CustomerForm);

    const emailInput = getByLabelText(/email/i);
    await fireEvent.input(emailInput, { target: { value: 'invalid-email' } });

    const submitButton = getByRole('button', { name: /submit/i });
    await fireEvent.click(submitButton);

    expect(getByText('Invalid email format')).toBeInTheDocument();
  });

  it('submits form with valid data', async () => {
    const mockSubmit = vi.fn();
    const { getByLabelText, getByRole } = render(CustomerForm, {
      props: { onSubmit: mockSubmit }
    });

    await fireEvent.input(getByLabelText(/name/i), {
      target: { value: 'John Doe' }
    });
    await fireEvent.input(getByLabelText(/email/i), {
      target: { value: 'john@example.com' }
    });

    const submitButton = getByRole('button', { name: /submit/i });
    await fireEvent.click(submitButton);

    expect(mockSubmit).toHaveBeenCalledWith({
      name: 'John Doe',
      email: 'john@example.com'
    });
  });
});
```

### Testing Lifecycle and Reactivity

#### Testing onMount and Cleanup
```javascript
// DataLoader.test.js
import { render, cleanup } from '@testing-library/svelte';
import DataLoader from './DataLoader.svelte';

describe('DataLoader Component', () => {
  afterEach(cleanup);

  it('loads data on mount', async () => {
    const mockFetch = vi.fn().mockResolvedValue({
      json: () => Promise.resolve({ data: ['item1', 'item2'] })
    });
    global.fetch = mockFetch;

    const { getByText } = render(DataLoader, {
      props: { endpoint: '/api/data' }
    });

    expect(mockFetch).toHaveBeenCalledWith('/api/data');
    
    // Wait for loading to complete
    await vi.waitFor(() => {
      expect(getByText('item1')).toBeInTheDocument();
    });
  });

  it('cleans up subscriptions on destroy', () => {
    const mockUnsubscribe = vi.fn();
    const mockSubscribe = vi.fn(() => mockUnsubscribe);

    const { unmount } = render(DataLoader, {
      props: { subscribe: mockSubscribe }
    });

    unmount();
    expect(mockUnsubscribe).toHaveBeenCalled();
  });
});
```

## Svelte Testing Best Practices

1. **Isolate Components**: Test components in isolation when possible
2. **Mock Dependencies**: Use vi.mock() for external dependencies
3. **User-Centric Testing**: Test from the user's perspective using Testing Library
4. **Avoid Implementation Details**: Test what components do, not how they do it
5. **Test Props and Events**: Verify components handle props and emit events correctly
6. **Snapshot Testing**: Use sparingly for UI stability checks
7. **Test Accessibility**: Verify components meet accessibility standards

### Testing Accessibility
```javascript
// Accessibility testing with jest-axe
import { render } from '@testing-library/svelte';
import { axe, toHaveNoViolations } from 'jest-axe';
import Button from './Button.svelte';

expect.extend(toHaveNoViolations);

describe('Button Accessibility', () => {
  it('should be accessible', async () => {
    const { container } = render(Button, {
      props: { text: 'Click me' }
    });

    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  it('supports keyboard navigation', () => {
    const { getByRole } = render(Button, {
      props: { text: 'Click me' }
    });

    const button = getByRole('button');
    expect(button).toHaveAttribute('tabindex', '0');
  });
});
```

### Testing Responsive Behavior
```javascript
// ResponsiveComponent.test.js
import { render } from '@testing-library/svelte';
import ResponsiveComponent from './ResponsiveComponent.svelte';

describe('ResponsiveComponent', () => {
  it('shows mobile layout on small screens', () => {
    // Mock window.innerWidth
    Object.defineProperty(window, 'innerWidth', {
      writable: true,
      configurable: true,
      value: 375,
    });

    const { container } = render(ResponsiveComponent);
    expect(container.firstChild).toHaveClass('mobile-layout');
  });

  it('shows desktop layout on large screens', () => {
    Object.defineProperty(window, 'innerWidth', {
      writable: true,
      configurable: true,
      value: 1200,
    });

    const { container } = render(ResponsiveComponent);
    expect(container.firstChild).toHaveClass('desktop-layout');
  });
});
```

### Performance Testing
Use watchMode for frontend testing during development to get rapid feedback on component changes.

Remember: Svelte tests should focus on component behavior, user interactions, and state management while avoiding testing framework internals.