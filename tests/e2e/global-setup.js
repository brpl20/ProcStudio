/**
 * Playwright Global Setup
 *
 * This file handles global setup for E2E tests, including:
 * - Database preparation
 * - Test user creation
 * - Authentication setup
 * - Environment validation
 */

const { chromium } = require('@playwright/test');
const axios = require('axios');
const path = require('path');
const fs = require('fs');

async function globalSetup(config) {
  console.log('🔧 Setting up E2E test environment...');

  const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:5173';
  const apiUrl = process.env.BASE_URL || 'http://localhost:3000';

  // Load test configuration
  const testConfigPath = path.join(__dirname, '../test_config.json');
  const testConfig = fs.existsSync(testConfigPath)
    ? JSON.parse(fs.readFileSync(testConfigPath, 'utf8'))
    : {};

  try {
    // 1. Wait for servers to be ready
    await waitForServers(apiUrl, frontendUrl);

    // 2. Setup test database
    await setupTestDatabase();

    // 3. Create test users
    await createTestUsers(apiUrl, testConfig);

    // 4. Setup authentication state
    await setupAuthState(apiUrl, testConfig);

    // 5. Create test data
    await createTestData(apiUrl, testConfig);

    console.log('✅ E2E test environment setup completed');

  } catch (error) {
    console.error('❌ E2E setup failed:', error.message);
    throw error;
  }
}

/**
 * Wait for both API and frontend servers to be ready
 */
async function waitForServers(apiUrl, frontendUrl, maxAttempts = 30) {
  console.log('⏳ Waiting for servers to be ready...');

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      // Check API server
      await axios.get(`${apiUrl}/health`, { timeout: 5000 });

      // Check frontend server
      await axios.get(frontendUrl, { timeout: 5000 });

      console.log(`✅ Both servers are ready (attempt ${attempt})`);
      return;
    } catch (error) {
      if (attempt === maxAttempts) {
        throw new Error(`Servers not ready after ${maxAttempts} attempts: ${error.message}`);
      }

      console.log(`⏳ Servers not ready, retrying... (attempt ${attempt}/${maxAttempts})`);
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }
}

/**
 * Setup test database with clean state
 */
async function setupTestDatabase() {
  console.log('🗄️  Setting up test database...');

  const { execSync } = require('child_process');
  const projectRoot = path.resolve(__dirname, '../..');

  try {
    // Reset test database
    execSync('RAILS_ENV=test bundle exec rails db:drop db:create db:migrate', {
      cwd: projectRoot,
      stdio: 'inherit',
      env: { ...process.env, RAILS_ENV: 'test' }
    });

    // Seed with test data
    execSync('RAILS_ENV=test bundle exec rails db:seed', {
      cwd: projectRoot,
      stdio: 'inherit',
      env: { ...process.env, RAILS_ENV: 'test' }
    });

    console.log('✅ Test database setup completed');
  } catch (error) {
    console.error('❌ Database setup failed:', error.message);
    throw error;
  }
}

/**
 * Create test users for E2E testing
 */
async function createTestUsers(apiUrl, testConfig) {
  console.log('👤 Creating test users...');

  const testUsers = [
    {
      email: 'admin@e2etest.procstudio.com',
      password: 'E2ETestPass123!',
      role: 'admin'
    },
    {
      email: 'user@e2etest.procstudio.com',
      password: 'E2ETestPass123!',
      role: 'user'
    },
    {
      email: 'lawyer@e2etest.procstudio.com',
      password: 'E2ETestPass123!',
      role: 'lawyer'
    }
  ];

  try {
    for (const user of testUsers) {
      try {
        const response = await axios.post(`${apiUrl}/users`, {
          user: user
        }, {
          headers: { 'Content-Type': 'application/json' },
          timeout: 10000
        });

        console.log(`✅ Created test user: ${user.email}`);
      } catch (error) {
        if (error.response?.status === 422) {
          console.log(`ℹ️  Test user already exists: ${user.email}`);
        } else {
          console.warn(`⚠️  Failed to create user ${user.email}:`, error.message);
        }
      }
    }

    // Store test user credentials in a file for tests to use
    const testUsersFile = path.join(__dirname, 'test-users.json');
    fs.writeFileSync(testUsersFile, JSON.stringify(testUsers, null, 2));
    console.log(`📝 Test user credentials saved to: ${testUsersFile}`);

  } catch (error) {
    console.error('❌ Test user creation failed:', error.message);
    throw error;
  }
}

/**
 * Setup authentication states for different user types
 */
async function setupAuthState(apiUrl, testConfig) {
  console.log('🔐 Setting up authentication states...');

  try {
    const browser = await chromium.launch();
    const storageStatesDir = path.join(__dirname, 'storage-states');

    if (!fs.existsSync(storageStatesDir)) {
      fs.mkdirSync(storageStatesDir, { recursive: true });
    }

    const testUsers = [
      {
        email: 'admin@e2etest.procstudio.com',
        password: 'E2ETestPass123!',
        role: 'admin'
      },
      {
        email: 'user@e2etest.procstudio.com',
        password: 'E2ETestPass123!',
        role: 'user'
      },
      {
        email: 'lawyer@e2etest.procstudio.com',
        password: 'E2ETestPass123!',
        role: 'lawyer'
      }
    ];

    for (const user of testUsers) {
      try {
        const context = await browser.newContext();
        const page = await context.newPage();

        // Navigate to login page
        await page.goto(`${process.env.FRONTEND_URL || 'http://localhost:5173'}/login`);

        // Perform login
        await page.fill('[data-testid="email"]', user.email);
        await page.fill('[data-testid="password"]', user.password);
        await page.click('[data-testid="login-button"]');

        // Wait for successful login (adjust selector based on your app)
        await page.waitForURL('**/dashboard', { timeout: 10000 });

        // Save authenticated state
        const storagePath = path.join(storageStatesDir, `${user.role}-state.json`);
        await context.storageState({ path: storagePath });

        console.log(`✅ Saved auth state for ${user.role}: ${storagePath}`);

        await context.close();
      } catch (error) {
        console.warn(`⚠️  Could not create auth state for ${user.role}:`, error.message);
      }
    }

    await browser.close();
  } catch (error) {
    console.warn('⚠️  Authentication state setup failed:', error.message);
    // Non-critical error - tests can still run with manual login
  }
}

/**
 * Create test data for E2E scenarios
 */
async function createTestData(apiUrl, testConfig) {
  console.log('📊 Creating test data...');

  try {
    // First authenticate to get a token
    const authResponse = await axios.post(`${apiUrl}/auth/login`, {
      email: 'admin@e2etest.procstudio.com',
      password: 'E2ETestPass123!'
    }, {
      headers: { 'Content-Type': 'application/json' }
    });

    const token = authResponse.data.token || authResponse.data.access_token;
    const authHeaders = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };

    // Create sample data that E2E tests will need
    const testData = {
      cases: [
        {
          title: 'E2E Test Case 1',
          description: 'Sample case for end-to-end testing',
          status: 'active'
        },
        {
          title: 'E2E Test Case 2',
          description: 'Another sample case for testing',
          status: 'pending'
        }
      ],
      clients: [
        {
          name: 'E2E Test Client',
          email: 'client@e2etest.com',
          phone: '(555) 123-4567'
        }
      ],
      documents: [
        {
          title: 'E2E Test Document',
          content: 'Sample document content for testing'
        }
      ]
    };

    // Create test data via API
    for (const [resource, items] of Object.entries(testData)) {
      for (const item of items) {
        try {
          await axios.post(`${apiUrl}/${resource}`, item, {
            headers: authHeaders,
            timeout: 10000
          });
          console.log(`✅ Created test ${resource.slice(0, -1)}: ${item.title || item.name}`);
        } catch (error) {
          if (error.response?.status !== 422) {
            console.warn(`⚠️  Failed to create ${resource.slice(0, -1)}:`, error.message);
          }
        }
      }
    }

    // Save test data references for tests
    const testDataFile = path.join(__dirname, 'test-data.json');
    fs.writeFileSync(testDataFile, JSON.stringify(testData, null, 2));
    console.log(`📝 Test data references saved to: ${testDataFile}`);

  } catch (error) {
    console.warn('⚠️  Test data creation failed:', error.message);
    // Non-critical - tests can create their own data
  }
}

module.exports = globalSetup;
