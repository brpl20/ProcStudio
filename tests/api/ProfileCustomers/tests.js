#!/usr/bin/env node

/**
 * Profile Customers Test Runner
 * Main entry point for running profile customer tests
 * 
 * Usage:
 *   npx mocha ./api/ProfileCustomers/tests.js                 # Run all tests
 *   npx mocha ./api/ProfileCustomers/tests.js --create        # Run only create tests
 *   npx mocha ./api/ProfileCustomers/tests.js --read          # Run only read tests
 *   npx mocha ./api/ProfileCustomers/tests.js --update        # Run only update tests
 *   npx mocha ./api/ProfileCustomers/tests.js --delete-soft   # Run only soft delete tests
 *   npx mocha ./api/ProfileCustomers/tests.js --delete-hard   # Run only hard delete tests
 *   npx mocha ./api/ProfileCustomers/tests.js --restore       # Run only restore tests
 *   npx mocha ./api/ProfileCustomers/tests.js --cascade       # Run only cascade deletion tests
 *   npx mocha ./api/ProfileCustomers/tests.js --authorization # Run only authorization tests
 *   npx mocha ./api/ProfileCustomers/tests.js --isolation     # Run only isolation tests
 */

const { runAllTests, runSpecificTest } = require('./index');

// Parse command line arguments
const args = process.argv.slice(2);

// Check for specific test flags
const testFlags = {
  '--create': 'create',
  '--read': 'read',
  '--update': 'update',
  '--delete-soft': 'delete-soft',
  '--delete-hard': 'delete-hard',
  '--restore': 'restore',
  '--cascade': 'cascade',
  '--authorization': 'authorization',
  '--isolation': 'isolation',
  // Short aliases
  '-c': 'create',
  '-r': 'read',
  '-u': 'update',
  '-ds': 'delete-soft',
  '-dh': 'delete-hard',
  '-rs': 'restore',
  '-cs': 'cascade',
  '-a': 'authorization',
  '-i': 'isolation'
};

// Find which test to run
let testToRun = null;
for (const arg of args) {
  if (testFlags[arg]) {
    testToRun = testFlags[arg];
    break;
  }
}

// Print header
console.log('P'.repeat(60));
console.log('  PROFILE CUSTOMERS API TEST SUITE');
console.log('P'.repeat(60));

// Run tests
if (testToRun) {
  console.log(`\n=� Running ${testToRun.toUpperCase()} tests only\n`);
  runSpecificTest(testToRun);
} else {
  console.log('\n=� Running ALL tests\n');
  console.log('Tip: Use flags to run specific tests:');
  console.log('  --create, --read, --update, --delete-soft, --delete-hard');
  console.log('  --restore, --cascade, --authorization, --isolation');
  console.log('  or short: -c, -r, -u, -ds, -dh, -rs, -cs, -a, -i\n');
  runAllTests();
}

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});