/**
 * API Test Runner
 * Runs all generated API tests
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

class ApiTestRunner {
  constructor() {
    this.testFiles = [
  "development_user_users_test.js",
  "development_user_profile_users_test.js",
  "development_user_teams_test.js",
  "development_user_jobs_test.js",
  "development_user_customers_test.js",
  "development_user_profile_customers_test.js",
  "development_user_represents_test.js",
  "development_user_offices_test.js",
  "development_user_office_types_test.js",
  "development_user_law_areas_test.js",
  "development_user_powers_test.js",
  "development_user_works_test.js",
  "development_user_draft_works_test.js",
  "development_user_work_event_test.js",
  "development_user_test.js",
  "development_customer_works_test.js",
  "development_customer_customers_test.js",
  "development_customer_profile_customers_test.js",
  "development_test.js"
];
    this.results = {};
  }

  async runSingleTest(testFile) {
    return new Promise((resolve) => {
      console.log(`\n🧪 Running ${testFile}...`);

      const mocha = spawn('npx', ['mocha', testFile, '--reporter', 'spec'], {
        cwd: __dirname,
        stdio: 'inherit'
      });

      mocha.on('close', (code) => {
        this.results[testFile] = code === 0;
        resolve(code === 0);
      });
    });
  }

  async runAllTests() {
    console.log('🚀 Starting API Tests...');
    console.log('═══════════════════════════');

    for (const testFile of this.testFiles) {
      if (fs.existsSync(path.join(__dirname, testFile))) {
        await this.runSingleTest(testFile);
      } else {
        console.log(`⚠️  Test file not found: ${testFile}`);
        this.results[testFile] = false;
      }
    }

    this.displaySummary();
  }

  displaySummary() {
    console.log('\n📊 API Test Results');
    console.log('═══════════════════');

    let passed = 0;
    let total = 0;

    Object.entries(this.results).forEach(([file, success]) => {
      const status = success ? '✅ PASSED' : '❌ FAILED';
      console.log(`${file}: ${status}`);
      if (success) passed++;
      total++;
    });

    console.log(`\nOverall: ${passed}/${total} test suites passed`);

    if (passed === total) {
      console.log('🎉 All API tests passed!');
      process.exit(0);
    } else {
      console.log('⚠️  Some API tests failed.');
      process.exit(1);
    }
  }
}

if (require.main === module) {
  const runner = new ApiTestRunner();
  runner.runAllTests().catch(console.error);
}

module.exports = ApiTestRunner;
