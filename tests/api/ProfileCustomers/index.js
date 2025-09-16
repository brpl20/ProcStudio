/**
 * Profile Customers API Test Facade
 * Central orchestrator for all profile customer tests
 */

const { testState, config } = require('./config');
const AuthHelper = require('../auth_helper');
const { runCreateTests } = require('./create');
const { runReadTests } = require('./read');
const { runUpdateTests } = require('./update');
const { runSoftDeleteTests } = require('./delete-soft');
const { runHardDeleteTests } = require('./delete-hard');
const { runIsolationTests } = require('./isolation');

/**
 * Initialize test suite
 */
const initialize = async () => {
  console.log('\n🚀 Initializing Profile Customers Test Suite...\n');
  
  // Debug config
  console.log('Config check:', {
    baseUrl: config.api.baseUrl,
    hasAuth: !!config.api.auth,
    hasCredentials: !!config.api.auth?.testCredentials,
    tokenEndpoint: config.api.auth?.tokenEndpoint
  });
  
  // Set up authentication
  testState.authHelper = new AuthHelper(config);
  await testState.authHelper.authenticate();
  
  console.log('✅ Authentication successful\n');
};

/**
 * Run all tests
 */
const runAllTests = () => {
  describe('Profile Customers API Tests', function() {
    this.timeout(30000);
    
    before(async function() {
      await initialize();
    });
    
    // Run tests in order
    runReadTests();     // Get index and show
    runCreateTests();   // POST
    runUpdateTests();   // PUT/PATCH
    runSoftDeleteTests(); // Soft DELETE
    runHardDeleteTests(); // Hard DELETE/destroy
    runIsolationTests(); // Security & Isolation
  });
};

/**
 * Run specific test based on command line argument
 */
const runSpecificTest = (testType) => {
  describe(`Profile Customers API - ${testType.toUpperCase()} Tests`, function() {
    this.timeout(30000);
    
    before(async function() {
      await initialize();
    });
    
    switch(testType.toLowerCase()) {
      case 'create':
        runCreateTests();
        break;
      case 'read':
        runReadTests();
        break;
      case 'update':
        runUpdateTests();
        break;
      case 'delete-soft':
        runSoftDeleteTests();
        break;
      case 'delete-hard':
        runHardDeleteTests();
        break;
      case 'isolation':
        runIsolationTests();
        break;
      default:
        console.error(`Unknown test type: ${testType}`);
        console.log('Available test types: create, read, update, delete-soft, delete-hard, isolation');
        process.exit(1);
    }
  });
};

/**
 * Export test runners
 */
module.exports = {
  runAllTests,
  runSpecificTest,
  // Export individual test runners for direct access
  runCreateTests,
  runReadTests,
  runUpdateTests,
  runSoftDeleteTests,
  runHardDeleteTests,
  runIsolationTests
};