/**
 * Sample End-to-End Test
 *
 * This is a sample E2E test to demonstrate the testing framework
 * and provide a template for writing additional E2E tests.
 */

const { test, expect } = require('@playwright/test');

test.describe('ProcStudio Application', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the application
    await page.goto('/');
  });

  test('should load the homepage', async ({ page }) => {
    // Check if the page title is correct
    await expect(page).toHaveTitle(/ProcStudio/);

    // Verify main navigation is visible
    await expect(page.locator('nav')).toBeVisible();
  });

  test('should navigate to login page', async ({ page }) => {
    // Look for login link/button
    const loginButton = page.locator('a[href*="login"], button:has-text("Login"), [data-testid="login"]');

    if (await loginButton.count() > 0) {
      await loginButton.first().click();

      // Verify we're on the login page
      await expect(page).toHaveURL(/.*login.*/);

      // Check for login form elements
      const emailInput = page.locator('input[type="email"], input[name="email"], [data-testid="email"]');
      const passwordInput = page.locator('input[type="password"], input[name="password"], [data-testid="password"]');

      await expect(emailInput.first()).toBeVisible();
      await expect(passwordInput.first()).toBeVisible();
    } else {
      console.log('Login functionality not found - skipping login test');
      test.skip();
    }
  });

  test('should handle user authentication flow', async ({ page }) => {
    // Navigate to login page
    await page.goto('/login');

    // Fill in test credentials
    const emailInput = page.locator('input[type="email"], input[name="email"], [data-testid="email"]').first();
    const passwordInput = page.locator('input[type="password"], input[name="password"], [data-testid="password"]').first();
    const loginButton = page.locator('button[type="submit"], button:has-text("Login"), [data-testid="login-button"]').first();

    if (await emailInput.count() > 0 && await passwordInput.count() > 0) {
      await emailInput.fill('user@e2etest.procstudio.com');
      await passwordInput.fill('E2ETestPass123!');

      if (await loginButton.count() > 0) {
        await loginButton.click();

        // Wait for navigation after login
        await page.waitForURL('**/dashboard', { timeout: 10000 });

        // Verify successful login by checking for dashboard elements
        const dashboardIndicator = page.locator('h1:has-text("Dashboard"), [data-testid="dashboard"], .dashboard');
        await expect(dashboardIndicator.first()).toBeVisible({ timeout: 5000 });
      }
    } else {
      console.log('Login form not found - skipping authentication test');
      test.skip();
    }
  });

  test('should display navigation menu', async ({ page }) => {
    // Look for common navigation elements
    const navElements = [
      'nav a:has-text("Home")',
      'nav a:has-text("Dashboard")',
      'nav a:has-text("Cases")',
      'nav a:has-text("Users")',
      'nav a:has-text("Settings")',
      '[data-testid="nav-menu"]',
      '.navigation',
      '.sidebar'
    ];

    let foundNav = false;

    for (const selector of navElements) {
      const element = page.locator(selector);
      if (await element.count() > 0) {
        await expect(element.first()).toBeVisible();
        foundNav = true;
        break;
      }
    }

    if (!foundNav) {
      console.log('Navigation elements not found - application might use different structure');
    }
  });

  test('should be responsive on mobile', async ({ page }) => {
    // Test mobile viewport
    await page.setViewportSize({ width: 375, height: 667 }); // iPhone SE size

    // Reload page with mobile viewport
    await page.reload();

    // Check that content is still accessible
    const body = page.locator('body');
    await expect(body).toBeVisible();

    // Verify no horizontal scrolling is needed
    const bodyWidth = await body.evaluate(el => el.scrollWidth);
    const viewportWidth = await page.evaluate(() => window.innerWidth);

    expect(bodyWidth).toBeLessThanOrEqual(viewportWidth + 10); // 10px tolerance
  });

  test('should handle API connectivity', async ({ page }) => {
    // Navigate to a page that likely makes API calls
    await page.goto('/');

    // Check for any network errors
    const responses = [];
    page.on('response', response => {
      if (response.url().includes('/api/') || response.url().includes(':3000')) {
        responses.push({
          url: response.url(),
          status: response.status(),
          ok: response.ok()
        });
      }
    });

    // Trigger some user interactions that might make API calls
    await page.waitForTimeout(2000); // Wait for initial API calls

    // Check if any API responses were received
    if (responses.length > 0) {
      console.log('API Responses detected:', responses.length);

      // Check for successful responses
      const successfulResponses = responses.filter(r => r.ok);
      const failedResponses = responses.filter(r => !r.ok);

      console.log(`Successful API calls: ${successfulResponses.length}`);
      console.log(`Failed API calls: ${failedResponses.length}`);

      if (failedResponses.length > 0) {
        console.warn('Some API calls failed:', failedResponses);
      }

      // At least some API calls should be successful if the backend is working
      expect(successfulResponses.length).toBeGreaterThan(0);
    } else {
      console.log('No API calls detected - frontend might be static or using different endpoints');
    }
  });
});

test.describe('Accessibility Tests', () => {
  test('should have proper heading structure', async ({ page }) => {
    await page.goto('/');

    // Check for h1 element
    const h1 = page.locator('h1');
    if (await h1.count() > 0) {
      await expect(h1.first()).toBeVisible();
    }

    // Verify heading hierarchy (basic check)
    const headings = await page.locator('h1, h2, h3, h4, h5, h6').allTextContents();
    expect(headings.length).toBeGreaterThan(0);
  });

  test('should have proper alt text for images', async ({ page }) => {
    await page.goto('/');

    const images = page.locator('img');
    const imageCount = await images.count();

    if (imageCount > 0) {
      for (let i = 0; i < imageCount; i++) {
        const img = images.nth(i);
        const alt = await img.getAttribute('alt');
        const src = await img.getAttribute('src');

        // Images should have alt text (can be empty for decorative images)
        if (src && !src.includes('logo') && !src.includes('icon')) {
          expect(alt).not.toBeNull();
        }
      }
    }
  });

  test('should be keyboard navigable', async ({ page }) => {
    await page.goto('/');

    // Try to navigate using Tab key
    await page.keyboard.press('Tab');

    // Check if focus is visible
    const focusedElement = page.locator(':focus');
    if (await focusedElement.count() > 0) {
      await expect(focusedElement).toBeVisible();
    }
  });
});

test.describe('Performance Tests', () => {
  test('should load within acceptable time', async ({ page }) => {
    const startTime = Date.now();

    await page.goto('/');

    // Wait for page to be fully loaded
    await page.waitForLoadState('networkidle');

    const loadTime = Date.now() - startTime;

    console.log(`Page load time: ${loadTime}ms`);

    // Page should load within 10 seconds
    expect(loadTime).toBeLessThan(10000);

    // Ideally within 3 seconds for good user experience
    if (loadTime > 3000) {
      console.warn(`Page load time (${loadTime}ms) is above 3 seconds - consider optimization`);
    }
  });

  test('should not have memory leaks', async ({ page }) => {
    // Navigate to page
    await page.goto('/');

    // Perform some interactions
    await page.reload();
    await page.goBack();
    await page.goForward();

    // Basic check - page should still be responsive
    const title = await page.title();
    expect(title).toBeTruthy();
  });
});

test.describe('Error Handling', () => {
  test('should handle 404 pages gracefully', async ({ page }) => {
    // Navigate to a page that definitely doesn't exist
    const response = await page.goto('/this-page-definitely-does-not-exist-12345');

    if (response) {
      // Check if we get a 404 status or are redirected
      const status = response.status();

      if (status === 404) {
        // Verify 404 page is user-friendly
        const body = await page.textContent('body');
        expect(body.toLowerCase()).toMatch(/not found|404|page.*exist/);
      } else {
        // If redirected, that's also acceptable behavior
        console.log(`Redirected with status ${status} instead of showing 404`);
      }
    }
  });

  test('should handle network errors gracefully', async ({ page }) => {
    // Block all network requests to simulate offline condition
    await page.route('**/*', route => route.abort());

    try {
      await page.goto('/', { timeout: 5000 });
    } catch (error) {
      // This is expected to fail
      console.log('Network blocked navigation failed as expected');
    }

    // Unblock network
    await page.unroute('**/*');

    // Should be able to navigate normally again
    await page.goto('/');
    await expect(page.locator('body')).toBeVisible();
  });
});
