/**
 * Playwright Global Teardown
 *
 * Minimal global teardown for E2E tests
 */

async function globalTeardown(config) {
  console.log("🧹 E2E test environment teardown...");

  // Just log that teardown is complete
  console.log("✅ E2E teardown complete");
}

module.exports = globalTeardown;
