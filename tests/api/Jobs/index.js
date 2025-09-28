/**
 * Jobs API Test Facade
 * Central orchestrator for all job tests
 */

const { testState, config } = require('./config');
const AuthHelper = require('../auth_helper');
const { inspectBackend } = require('./backend_inspector');
const { runCreateTests } = require('./create');
const { runReadTests } = require('./read');
const { runUpdateTests } = require('./update');
const { runSoftDeleteTests } = require('./delete-soft');
const { runHardDeleteTests } = require('./delete-hard');
const { runRestoreTests } = require('./restore');
const { runCascadeDeletionTests } = require('./cascade-deletion');
const { runAuthorizationDeletionTests } = require('./authorization-deletion');
const { runIsolationTests } = require('./isolation');

/**
 * Initialize test suite
 */
const initialize = async () => {
  console.log('\n🚀 Initializing Jobs Test Suite...\n');
  
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
  describe('Jobs API Tests', function() {
    this.timeout(30000);
    
    before(async function() {
      // Set flag for simplified output
      testState.isFullTestRun = true;
      
      // Run backend inspection first
      console.log('\n📋 Running backend inspection...');
      try {
        const inspectionResults = inspectBackend({ quiet: true });
        if (inspectionResults.changes.length > 0) {
          console.log(`⚠️  Backend changes detected! Consider running individual tests to verify.`);
        }
      } catch (error) {
        console.log(`⚠️  Backend inspection failed: ${error.message}`);
      }
      
      await initialize();
    });
    
    // Run tests in order
    runReadTests();     // Get index and show
    runCreateTests();   // POST
    runUpdateTests();   // PUT/PATCH
    runSoftDeleteTests(); // Soft DELETE
    runHardDeleteTests(); // Hard DELETE/destroy
    runRestoreTests();  // Restore from soft delete
    runCascadeDeletionTests(); // Cascade deletion behavior
    runAuthorizationDeletionTests(); // Authorization and error handling
    runIsolationTests(); // Security & Isolation
  });
};

/**
 * Run specific test based on command line argument
 */
const runSpecificTest = (testType) => {
  describe(`Jobs API - ${testType.toUpperCase()} Tests`, function() {
    this.timeout(30000);
    
    before(async function() {
      // Don't set isFullTestRun flag for individual tests
      testState.isFullTestRun = false;
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
      case 'restore':
        runRestoreTests();
        break;
      case 'cascade':
        runCascadeDeletionTests();
        break;
      case 'authorization':
        runAuthorizationDeletionTests();
        break;
      case 'isolation':
        runIsolationTests();
        break;
      default:
        console.error(`Unknown test type: ${testType}`);
        console.log('Available test types: create, read, update, delete-soft, delete-hard, restore, cascade, authorization, isolation');
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
  runRestoreTests,
  runCascadeDeletionTests,
  runAuthorizationDeletionTests,
  runIsolationTests
};
