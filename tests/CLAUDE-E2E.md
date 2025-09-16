# End-to-End Testing Guidelines

## Testing Tools
- **Playwright**: Primary E2E testing framework
- **Cypress**: Alternative E2E testing framework

## Playwright Setup & Configuration

### Basic Configuration
```javascript
// playwright.config.js
export default {
  testDir: './e2e',
  timeout: 30000,
  retries: 2,
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:5173',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'mobile',
      use: { ...devices['iPhone 13'] },
    },
  ],
};
```

## E2E Testing Best Practices

### 1. Page Object Model
```javascript
// pages/CustomerPage.js
export class CustomerPage {
  constructor(page) {
    this.page = page;
    this.searchInput = page.locator('[data-testid="customer-search"]');
    this.customerList = page.locator('[data-testid="customer-list"]');
    this.addButton = page.locator('[data-testid="add-customer-btn"]');
  }

  async searchCustomer(name) {
    await this.searchInput.fill(name);
    await this.page.keyboard.press('Enter');
  }

  async waitForCustomersToLoad() {
    await this.customerList.waitFor({ state: 'visible' });
  }
}
```

### 2. Test Structure
```javascript
// e2e/customer-management.spec.js
import { test, expect } from '@playwright/test';
import { CustomerPage } from './pages/CustomerPage';

test.describe('Customer Management', () => {
  let customerPage;

  test.beforeEach(async ({ page }) => {
    customerPage = new CustomerPage(page);
    await page.goto('/customers');
  });

  test('should display customer list', async ({ page }) => {
    await customerPage.waitForCustomersToLoad();
    const customers = await customerPage.customerList.count();
    expect(customers).toBeGreaterThan(0);
  });

  test('should search for customers', async ({ page }) => {
    await customerPage.searchCustomer('John');
    await page.waitForResponse('**/api/v1/customers*');

    const results = await customerPage.customerList.locator('.customer-card').count();
    expect(results).toBeGreaterThan(0);

    // Verify search results contain search term
    const firstResult = await customerPage.customerList.locator('.customer-card').first();
    await expect(firstResult).toContainText('John');
  });

  test('should create new customer', async ({ page }) => {
    await customerPage.addButton.click();

    // Fill form
    await page.fill('[data-testid="name-input"]', 'Jane Doe');
    await page.fill('[data-testid="email-input"]', 'jane@example.com');
    await page.fill('[data-testid="phone-input"]', '555-0123');

    // Submit and verify
    await page.click('[data-testid="submit-btn"]');
    await expect(page).toHaveURL(/\/customers\/\d+/);
    await expect(page.locator('h1')).toContainText('Jane Doe');
  });
});
```

### 3. API Mocking for Isolated Tests
```javascript
test('should handle API errors gracefully', async ({ page }) => {
  // Mock API error response
  await page.route('**/api/v1/customers', route => {
    route.fulfill({
      status: 500,
      contentType: 'application/json',
      body: JSON.stringify({ error: 'Internal Server Error' })
    });
  });

  await page.goto('/customers');
  await expect(page.locator('.error-message')).toContainText('Failed to load customers');
});
```

### 4. Authentication Testing
```javascript
test.describe('Authenticated flows', () => {
  test.use({ storageState: 'auth.json' }); // Pre-saved auth state

  test('should access protected routes', async ({ page }) => {
    await page.goto('/dashboard');
    await expect(page).not.toHaveURL('/login');
    await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();
  });
});

test.describe('Authentication flow', () => {
  test('should login successfully', async ({ page }) => {
    await page.goto('/login');
    await page.fill('[data-testid="email-input"]', 'user@example.com');
    await page.fill('[data-testid="password-input"]', 'password123');
    await page.click('[data-testid="login-button"]');
    
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();
  });

  test('should handle login errors', async ({ page }) => {
    await page.goto('/login');
    await page.fill('[data-testid="email-input"]', 'wrong@example.com');
    await page.fill('[data-testid="password-input"]', 'wrongpassword');
    await page.click('[data-testid="login-button"]');
    
    await expect(page.locator('.error-message')).toContainText('Invalid credentials');
  });
});
```

### 5. Visual Regression Testing
```javascript
test('visual regression - customer list', async ({ page }) => {
  await page.goto('/customers');
  await customerPage.waitForCustomersToLoad();
  await expect(page).toHaveScreenshot('customer-list.png', {
    fullPage: true,
    animations: 'disabled'
  });
});

test('visual regression - mobile view', async ({ page }) => {
  await page.setViewportSize({ width: 375, height: 667 });
  await page.goto('/customers');
  await customerPage.waitForCustomersToLoad();
  await expect(page).toHaveScreenshot('customer-list-mobile.png');
});
```

### 6. Performance Testing
```javascript
test('should load customer list within 3 seconds', async ({ page }) => {
  const startTime = Date.now();
  await page.goto('/customers');
  await customerPage.waitForCustomersToLoad();
  const loadTime = Date.now() - startTime;

  expect(loadTime).toBeLessThan(3000);
});

test('should handle large datasets efficiently', async ({ page }) => {
  // Setup: Create large dataset via API
  await page.request.post('/api/v1/test/customers/bulk', {
    data: { count: 1000 }
  });

  const startTime = Date.now();
  await page.goto('/customers');
  await customerPage.waitForCustomersToLoad();
  const loadTime = Date.now() - startTime;

  expect(loadTime).toBeLessThan(5000);
});
```

### 7. Form Testing
```javascript
test.describe('Customer form', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/customers/new');
  });

  test('should validate required fields', async ({ page }) => {
    await page.click('[data-testid="submit-btn"]');
    
    await expect(page.locator('[data-testid="name-error"]')).toContainText('Name is required');
    await expect(page.locator('[data-testid="email-error"]')).toContainText('Email is required');
  });

  test('should validate email format', async ({ page }) => {
    await page.fill('[data-testid="email-input"]', 'invalid-email');
    await page.click('[data-testid="submit-btn"]');
    
    await expect(page.locator('[data-testid="email-error"]')).toContainText('Invalid email format');
  });

  test('should save form data on successful submission', async ({ page }) => {
    await page.fill('[data-testid="name-input"]', 'John Doe');
    await page.fill('[data-testid="email-input"]', 'john@example.com');
    await page.click('[data-testid="submit-btn"]');
    
    await expect(page).toHaveURL(/\/customers\/\d+/);
    await expect(page.locator('h1')).toContainText('John Doe');
  });
});
```

### 8. Accessibility Testing
```javascript
import { injectAxe, checkA11y } from 'axe-playwright';

test('should be accessible', async ({ page }) => {
  await page.goto('/customers');
  await injectAxe(page);
  await checkA11y(page);
});

test('should support keyboard navigation', async ({ page }) => {
  await page.goto('/customers');
  
  // Tab through interactive elements
  await page.keyboard.press('Tab');
  await expect(page.locator('[data-testid="search-input"]')).toBeFocused();
  
  await page.keyboard.press('Tab');
  await expect(page.locator('[data-testid="add-button"]')).toBeFocused();
});
```

## E2E Testing Guidelines

### Test Organization
- Test critical user journeys first
- Use data-testid attributes for reliable selectors
- Avoid testing implementation details
- Mock external dependencies when appropriate
- Run tests in CI/CD pipeline
- Use parallel execution for faster feedback
- Implement retry logic for flaky tests
- Generate test reports with screenshots/videos
- Test across different browsers and devices
- Keep tests independent and idempotent

### Best Practices
1. **Reliable Selectors**: Use `data-testid` attributes instead of CSS classes or text content
2. **Wait Strategies**: Use explicit waits for elements and API responses
3. **Test Independence**: Each test should be able to run in isolation
4. **Data Cleanup**: Clean up test data after each test
5. **Error Scenarios**: Test both happy paths and error conditions
6. **Cross-browser Testing**: Test on multiple browsers and devices
7. **Performance Monitoring**: Include performance assertions in critical flows

### Common Patterns

#### Waiting for API Responses
```javascript
test('should update data after API call', async ({ page }) => {
  await page.click('[data-testid="refresh-btn"]');
  await page.waitForResponse('**/api/v1/customers**');
  await expect(page.locator('[data-testid="customer-list"]')).toBeVisible();
});
```

#### Handling Dynamic Content
```javascript
test('should handle loading states', async ({ page }) => {
  await page.goto('/customers');
  
  // Wait for loading to finish
  await expect(page.locator('[data-testid="loading-spinner"]')).toBeHidden();
  await expect(page.locator('[data-testid="customer-list"]')).toBeVisible();
});
```

#### File Upload Testing
```javascript
test('should upload customer avatar', async ({ page }) => {
  await page.goto('/customers/1/edit');
  
  const fileInput = page.locator('[data-testid="avatar-upload"]');
  await fileInput.setInputFiles('test-files/avatar.jpg');
  
  await page.click('[data-testid="save-btn"]');
  await expect(page.locator('[data-testid="avatar-image"]')).toBeVisible();
});
```

Remember: E2E tests should simulate real user interactions and verify complete workflows from the user's perspective.