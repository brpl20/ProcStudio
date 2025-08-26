/**
 * Playwright Configuration for End-to-End Tests
 *
 * This configuration sets up Playwright for comprehensive E2E testing
 * of the ProcStudio application (Svelte frontend + Rails API backend).
 */

const { defineConfig, devices } = require('@playwright/test');
const path = require('path');
const fs = require('fs');

// Load test configuration
const testConfigPath = path.join(__dirname, '../test_config.json');
const testConfig = fs.existsSync(testConfigPath)
  ? JSON.parse(fs.readFileSync(testConfigPath, 'utf8'))
  : {};

const e2eConfig = testConfig.e2e || {};
const frontendUrl = process.env.FRONTEND_URL || e2eConfig.baseUrl || 'http://localhost:5173';
const apiUrl = process.env.BASE_URL || testConfig.api?.baseUrl || 'http://localhost:3000';

module.exports = defineConfig({
  // Test directory
  testDir: './tests',

  // Run tests in files in parallel
  fullyParallel: true,

  // Fail the build on CI if you accidentally left test.only in the source code
  forbidOnly: !!process.env.CI,

  // Retry on CI only
  retries: process.env.CI ? 2 : 0,

  // Opt out of parallel tests on CI
  workers: process.env.CI ? 1 : undefined,

  // Reporter to use
  reporter: [
    ['html', { outputFolder: '../reports/e2e-html-report' }],
    ['json', { outputFile: '../reports/e2e-results.json' }],
    ['junit', { outputFile: '../reports/e2e-results.xml' }],
    process.env.CI ? ['github'] : ['list']
  ],

  // Global test timeout
  timeout: e2eConfig.timeout || 60000,

  // Global setup and teardown
  globalSetup: require.resolve('./global-setup'),
  globalTeardown: require.resolve('./global-teardown'),

  // Shared settings for all the projects below
  use: {
    // Base URL to use in actions like `await page.goto('/')`
    baseURL: frontendUrl,

    // Browser context options
    viewport: e2eConfig.viewport || { width: 1280, height: 720 },

    // Collect trace when retrying the failed test
    trace: 'on-first-retry',

    // Record video on failure
    video: e2eConfig.videos ? 'retain-on-failure' : 'off',

    // Take screenshot on failure
    screenshot: e2eConfig.screenshots ? 'only-on-failure' : 'off',

    // Ignore HTTPS errors
    ignoreHTTPSErrors: true,

    // Default navigation timeout
    navigationTimeout: 30000,

    // Default action timeout
    actionTimeout: 10000
  },

  // Configure projects for major browsers
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
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },

    // Mobile browsers
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },

    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] },
    },

    // Branded browsers
    {
      name: 'Microsoft Edge',
      use: { ...devices['Desktop Edge'], channel: 'msedge' },
    },

    {
      name: 'Google Chrome',
      use: { ...devices['Desktop Chrome'], channel: 'chrome' },
    },
  ],

  // Run your local dev server before starting the tests
  webServer: [
    // Rails API server
    {
      command: 'bundle exec rails server -p 3000',
      port: 3000,
      cwd: path.resolve(__dirname, '../..'),
      reuseExistingServer: !process.env.CI,
      env: {
        RAILS_ENV: 'test'
      },
      timeout: 120000
    },

    // Svelte frontend server
    {
      command: 'npm run dev',
      port: 5173,
      cwd: path.resolve(__dirname, '../../frontend'),
      reuseExistingServer: !process.env.CI,
      timeout: 120000
    }
  ],

  // Test match patterns
  testMatch: [
    '**/*.e2e.js',
    '**/*.e2e.ts',
    '**/e2e/**/*.spec.js',
    '**/e2e/**/*.spec.ts',
    '**/tests/**/*.test.js',
    '**/tests/**/*.test.ts'
  ],

  // Files to ignore
  testIgnore: [
    '**/node_modules/**',
    '**/dist/**',
    '**/build/**',
    '**/.git/**'
  ],

  // Global test configuration
  expect: {
    // Maximum time expect() should wait for the condition to be met
    timeout: 5000,

    // Threshold for screenshot comparison
    threshold: 0.5,

    // Threshold for text comparison
    toMatchSnapshot: {
      threshold: 0.2,
      mode: 'pixel'
    }
  },

  // Metadata
  metadata: {
    'test-environment': process.env.NODE_ENV || 'test',
    'frontend-url': frontendUrl,
    'api-url': apiUrl,
    'ci': !!process.env.CI,
    'browser-versions': {
      'chromium': 'latest',
      'firefox': 'latest',
      'webkit': 'latest'
    }
  }
});

// Export configuration for use in other files
module.exports.frontendUrl = frontendUrl;
module.exports.apiUrl = apiUrl;
module.exports.testConfig = testConfig;
