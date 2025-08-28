/**
 * Playwright Configuration for End-to-End Tests
 *
 * This configuration sets up Playwright for comprehensive E2E testing
 * of the ProcStudio application (Svelte frontend + Rails API backend).
 * Configuration is imported from ../config.js for consistency across test suites.
 */

const { defineConfig, devices } = require("@playwright/test");
const path = require("path");

// Import shared configuration from ../config.js
const { apiTesting } = require("../config.js");

// Extract configuration values
const baseApiUrl = apiTesting.api.baseUrl;
const apiUrl = apiTesting.api.baseUrl;
const frontendUrl = process.env.FRONTEND_URL || "http://localhost:5173";
const timeout = apiTesting.api.timeout * 60; // Convert to milliseconds for Playwright
const retries = apiTesting.api.retries;

module.exports = defineConfig({
  // Test directory
  testDir: "./tests",

  // Run tests in files in parallel
  fullyParallel: true,

  // Fail the build on CI if you accidentally left test.only in the source code
  forbidOnly: !!process.env.CI,

  // Retry configuration from shared config
  retries: process.env.CI ? retries : 0,

  // Opt out of parallel tests on CI
  workers: process.env.CI ? 1 : undefined,

  // Reporter to use
  reporter: [
    ["html", { outputFolder: "../reports/e2e-html-report" }],
    ["json", { outputFile: "../reports/e2e-results.json" }],
    ["junit", { outputFile: "../reports/e2e-results.xml" }],
    process.env.CI ? ["github"] : ["list"],
  ],

  // Global test timeout (convert from shared config)
  timeout: timeout * 1000, // Convert to milliseconds

  // No global setup/teardown - tests handle their own setup

  // Shared settings for all the projects below
  use: {
    // Base URL to use in actions like `await page.goto('/')`
    baseURL: frontendUrl,

    // Browser context options
    viewport: { width: 1280, height: 720 },

    // Collect trace when retrying the failed test
    trace: "on-first-retry",

    // Record video on failure
    video: "retain-on-failure",

    // Take screenshot on failure
    screenshot: "only-on-failure",

    // Ignore HTTPS errors
    ignoreHTTPSErrors: true,

    // Default navigation timeout
    navigationTimeout: 30000,

    // Default action timeout
    actionTimeout: 10000,

    // Extra HTTP headers to be sent with every request
    extraHTTPHeaders: {
      ...apiTesting.api.headers,
    },
  },

  // Configure projects for major browsers
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },

    {
      name: "firefox",
      use: { ...devices["Desktop Firefox"] },
    },

    {
      name: "webkit",
      use: { ...devices["Desktop Safari"] },
    },

    // Mobile browsers
    {
      name: "Mobile Chrome",
      use: { ...devices["Pixel 5"] },
    },

    {
      name: "Mobile Safari",
      use: { ...devices["iPhone 12"] },
    },

    // Branded browsers
    {
      name: "Microsoft Edge",
      use: { ...devices["Desktop Edge"], channel: "msedge" },
    },

    {
      name: "Google Chrome",
      use: { ...devices["Desktop Chrome"], channel: "chrome" },
    },
  ],

  // Tests will use existing servers - no auto-start
  // Make sure your servers are running:
  // Rails API: bundle exec rails server -p 3000
  // Frontend: npm run dev (port 5173)

  // Test match patterns
  testMatch: [
    "**/*.e2e.js",
    "**/*.e2e.ts",
    "**/e2e/**/*.spec.js",
    "**/e2e/**/*.spec.ts",
    "**/tests/**/*.test.js",
    "**/tests/**/*.test.ts",
  ],

  // Files to ignore
  testIgnore: ["**/node_modules/**", "**/dist/**", "**/build/**", "**/.git/**"],

  // Global test configuration
  expect: {
    // Maximum time expect() should wait for the condition to be met
    timeout: 5000,

    // Threshold for screenshot comparison
    threshold: 0.5,

    // Threshold for text comparison
    toMatchSnapshot: {
      threshold: 0.2,
      mode: "pixel",
    },
  },

  // Metadata
  metadata: {
    "test-environment": process.env.NODE_ENV || "test",
    "frontend-url": frontendUrl,
    "api-url": apiUrl,
    "api-timeout": apiTesting.api.timeout,
    "api-retries": apiTesting.api.retries,
    "auth-type": apiTesting.api.auth.type,
    "auth-endpoint": apiTesting.api.auth.tokenEndpoint,
    ci: !!process.env.CI,
    "browser-versions": {
      chromium: "latest",
      firefox: "latest",
      webkit: "latest",
    },
  },
});

// Export configuration for use in other files
module.exports.frontendUrl = frontendUrl;
module.exports.apiUrl = apiUrl;
module.exports.baseApiUrl = baseApiUrl;
module.exports.apiConfig = apiTesting.api;
module.exports.authConfig = apiTesting.api.auth;
