/**
 * Playwright Global Setup
 *
 * Minimal global setup - most setup is handled by individual tests
 */

async function globalSetup(config) {
  console.log("🔧 Minimal E2E test environment setup...");

  // Just log that setup is starting
  console.log("✅ E2E test environment ready");

  return;
}

module.exports = globalSetup;
