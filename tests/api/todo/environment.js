/**
 * Environment Configuration for API Tests
 */

const path = require('path');
const fs = require('fs');

class EnvironmentConfig {
  constructor() {
    this.loadEnvironment();
  }

  loadEnvironment() {
    // Load from environment variables or use defaults
    this.env = process.env.NODE_ENV || 'test';
    this.baseUrl = process.env.BASE_URL || 'http://localhost:3000';
    this.frontendUrl = process.env.FRONTEND_URL || 'http://localhost:5173';
    this.databaseUrl = process.env.DATABASE_URL || 'postgres://localhost/procstudio_test';

    // Load test config
    const configPath = path.join(__dirname, '../test_config.json');
    this.config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  }

  /**
   * Get environment-specific configuration
   */
  getConfig(environment = null) {
    const env = environment || this.env;

    const baseConfig = {
      environment: env,
      api: {
        baseUrl: this.baseUrl,
        timeout: this.config.api.timeout,
        retries: this.config.api.retries
      },
      frontend: {
        baseUrl: this.frontendUrl,
        timeout: this.config.frontend.timeout
      },
      database: {
        url: this.databaseUrl,
        resetBetweenTests: this.config.database.resetBetweenTests
      }
    };

    // Merge environment-specific overrides
    if (this.config.environments && this.config.environments[env]) {
      const envConfig = this.config.environments[env];

      if (envConfig.railsPort) {
        baseConfig.api.baseUrl = `http://localhost:${envConfig.railsPort}`;
      }

      if (envConfig.frontendPort) {
        baseConfig.frontend.baseUrl = `http://localhost:${envConfig.frontendPort}`;
      }

      if (envConfig.database) {
        baseConfig.database.url = envConfig.database;
      }

      // Merge other environment-specific settings
      Object.assign(baseConfig, envConfig);
    }

    return baseConfig;
  }

  /**
   * Check if we're in CI environment
   */
  isCI() {
    return process.env.CI === 'true' || process.env.GITHUB_ACTIONS === 'true';
  }

  /**
   * Get test credentials for environment
   */
  getTestCredentials() {
    return {
      admin: {
        email: process.env.TEST_ADMIN_EMAIL || this.config.api.auth.testCredentials.email,
        password: process.env.TEST_ADMIN_PASSWORD || this.config.api.auth.testCredentials.password
      },
      user: {
        email: process.env.TEST_USER_EMAIL || 'testuser@procstudio.test',
        password: process.env.TEST_USER_PASSWORD || 'testpass123'
      }
    };
  }

  /**
   * Set up environment variables for tests
   */
  setupTestEnvironment() {
    const config = this.getConfig();

    process.env.BASE_URL = config.api.baseUrl;
    process.env.FRONTEND_URL = config.frontend.baseUrl;
    process.env.DATABASE_URL = config.database.url;
    process.env.RAILS_ENV = 'test';

    console.log('🔧 Test environment configured:');
    console.log(`   API URL: ${config.api.baseUrl}`);
    console.log(`   Frontend URL: ${config.frontend.baseUrl}`);
    console.log(`   Environment: ${config.environment}`);
  }
}

const envConfig = new EnvironmentConfig();

module.exports = {
  EnvironmentConfig,
  envConfig,
  getConfig: (env) => envConfig.getConfig(env),
  setupTestEnvironment: () => envConfig.setupTestEnvironment(),
  isCI: () => envConfig.isCI(),
  getTestCredentials: () => envConfig.getTestCredentials()
};
