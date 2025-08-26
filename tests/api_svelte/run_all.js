#!/usr/bin/env node

/**
 * API-Svelte Integration Test Runner
 *
 * This script runs all integration tests between the Svelte frontend
 * and Rails API backend, providing a comprehensive test suite for
 * frontend-backend communication.
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const SvelteApiIntegration = require('./integration_tests');

class ApiSvelteTestRunner {
  constructor() {
    this.testFiles = [
      'integration_tests.js',
      'auth_flow_test.js',
      'data_flow_test.js',
      'error_handling_test.js',
      'performance_test.js'
    ];
    this.results = {};
    this.config = this.loadConfig();
  }

  loadConfig() {
    const configPath = path.join(__dirname, '../test_config.json');
    if (fs.existsSync(configPath)) {
      return JSON.parse(fs.readFileSync(configPath, 'utf8'));
    }
    return {};
  }

  /**
   * Check prerequisites before running tests
   */
  async checkPrerequisites() {
    console.log('🔍 Checking prerequisites...');

    // Check if Rails server is running
    try {
      const { default: fetch } = await import('node-fetch');
      const apiUrl = this.config.api?.baseUrl || 'http://localhost:3000';
      await fetch(`${apiUrl}/health`, { timeout: 5000 });
      console.log('✅ Rails API server is running');
    } catch (error) {
      console.error('❌ Rails API server is not accessible');
      console.log('   Please start the Rails server: bundle exec rails server');
      return false;
    }

    // Check if Svelte server is running
    try {
      const { default: fetch } = await import('node-fetch');
      const frontendUrl = this.config.frontend?.baseUrl || 'http://localhost:5173';
      await fetch(frontendUrl, { timeout: 5000 });
      console.log('✅ Svelte frontend server is running');
    } catch (error) {
      console.error('❌ Svelte frontend server is not accessible');
      console.log('   Please start the Svelte server: cd frontend && npm run dev');
      return false;
    }

    return true;
  }

  /**
   * Run the main integration test suite
   */
  async runIntegrationTests() {
    console.log('\n🧪 Running API-Svelte Integration Tests...');
    console.log('═══════════════════════════════════════════════');

    try {
      const integration = new SvelteApiIntegration();
      const success = await integration.runAllTests();

      this.results['integration_tests'] = {
        success,
        details: 'Main integration test suite'
      };

      return success;
    } catch (error) {
      console.error('❌ Integration tests failed:', error.message);
      this.results['integration_tests'] = {
        success: false,
        error: error.message
      };
      return false;
    }
  }

  /**
   * Run authentication flow tests
   */
  async runAuthFlowTests() {
    console.log('\n🔐 Testing Authentication Flow...');
    console.log('════════════════════════════════════');

    const testPath = path.join(__dirname, 'auth_flow_test.js');
    if (!fs.existsSync(testPath)) {
      console.log('ℹ️  Auth flow test file not found, skipping...');
      return true;
    }

    return this.runSingleTest('auth_flow_test.js', 'Authentication Flow Tests');
  }

  /**
   * Run data flow tests
   */
  async runDataFlowTests() {
    console.log('\n📊 Testing Data Flow...');
    console.log('═══════════════════════');

    const testPath = path.join(__dirname, 'data_flow_test.js');
    if (!fs.existsSync(testPath)) {
      console.log('ℹ️  Data flow test file not found, skipping...');
      return true;
    }

    return this.runSingleTest('data_flow_test.js', 'Data Flow Tests');
  }

  /**
   * Run error handling tests
   */
  async runErrorHandlingTests() {
    console.log('\n⚠️  Testing Error Handling...');
    console.log('═══════════════════════════════');

    const testPath = path.join(__dirname, 'error_handling_test.js');
    if (!fs.existsSync(testPath)) {
      console.log('ℹ️  Error handling test file not found, skipping...');
      return true;
    }

    return this.runSingleTest('error_handling_test.js', 'Error Handling Tests');
  }

  /**
   * Run performance tests
   */
  async runPerformanceTests() {
    console.log('\n⚡ Testing Performance...');
    console.log('═══════════════════════');

    const testPath = path.join(__dirname, 'performance_test.js');
    if (!fs.existsSync(testPath)) {
      console.log('ℹ️  Performance test file not found, skipping...');
      return true;
    }

    return this.runSingleTest('performance_test.js', 'Performance Tests');
  }

  /**
   * Run a single test file
   */
  async runSingleTest(testFile, description) {
    return new Promise((resolve) => {
      console.log(`Running ${testFile}...`);

      const testProcess = spawn('node', [testFile], {
        cwd: __dirname,
        stdio: 'inherit'
      });

      testProcess.on('close', (code) => {
        const success = code === 0;
        this.results[testFile] = {
          success,
          description,
          exitCode: code
        };

        if (success) {
          console.log(`✅ ${description} completed successfully`);
        } else {
          console.log(`❌ ${description} failed with exit code ${code}`);
        }

        resolve(success);
      });

      testProcess.on('error', (error) => {
        console.error(`❌ Error running ${testFile}:`, error.message);
        this.results[testFile] = {
          success: false,
          description,
          error: error.message
        };
        resolve(false);
      });
    });
  }

  /**
   * Run all test suites
   */
  async runAllTests() {
    console.log('🚀 Starting API-Svelte Integration Test Suite');
    console.log('══════════════════════════════════════════════');

    // Check prerequisites
    if (!(await this.checkPrerequisites())) {
      console.log('\n❌ Prerequisites not met. Please fix the issues above and try again.');
      process.exit(1);
    }

    const startTime = Date.now();

    // Run test suites
    const testSuites = [
      () => this.runIntegrationTests(),
      () => this.runAuthFlowTests(),
      () => this.runDataFlowTests(),
      () => this.runErrorHandlingTests(),
      () => this.runPerformanceTests()
    ];

    let allPassed = true;

    for (const testSuite of testSuites) {
      try {
        const result = await testSuite();
        if (!result) {
          allPassed = false;
        }
      } catch (error) {
        console.error('Test suite crashed:', error.message);
        allPassed = false;
      }
    }

    const duration = Date.now() - startTime;
    this.displaySummary(duration);

    return allPassed;
  }

  /**
   * Display test results summary
   */
  displaySummary(duration) {
    console.log('\n📊 API-Svelte Integration Test Summary');
    console.log('═══════════════════════════════════════');

    let passed = 0;
    let failed = 0;

    Object.entries(this.results).forEach(([testName, result]) => {
      const status = result.success ? '✅ PASSED' : '❌ FAILED';
      const description = result.description || testName;

      console.log(`${status} - ${description}`);

      if (result.error) {
        console.log(`          Error: ${result.error}`);
      }

      if (result.success) {
        passed++;
      } else {
        failed++;
      }
    });

    console.log(`\nResults: ${passed} passed, ${failed} failed`);
    console.log(`Duration: ${(duration / 1000).toFixed(2)} seconds`);

    if (failed === 0) {
      console.log('\n🎉 All API-Svelte integration tests passed!');
      console.log('   Frontend-backend communication is working correctly.');
    } else {
      console.log('\n⚠️  Some integration tests failed.');
      console.log('   Check the output above for details.');

      if (this.results['integration_tests'] && !this.results['integration_tests'].success) {
        console.log('\n❌ CRITICAL: Main integration tests failed!');
        console.log('   This indicates serious issues with frontend-backend communication.');
        console.log('   Please review and fix the issues before deploying.');
      }
    }

    // Generate test report
    this.generateTestReport(duration);
  }

  /**
   * Generate test report file
   */
  generateTestReport(duration) {
    const reportsDir = path.join(__dirname, '../reports');
    if (!fs.existsSync(reportsDir)) {
      fs.mkdirSync(reportsDir, { recursive: true });
    }

    const report = {
      testSuite: 'API-Svelte Integration Tests',
      timestamp: new Date().toISOString(),
      duration: `${(duration / 1000).toFixed(2)}s`,
      results: this.results,
      summary: {
        total: Object.keys(this.results).length,
        passed: Object.values(this.results).filter(r => r.success).length,
        failed: Object.values(this.results).filter(r => !r.success).length
      },
      environment: {
        apiBaseUrl: this.config.api?.baseUrl || 'http://localhost:3000',
        frontendBaseUrl: this.config.frontend?.baseUrl || 'http://localhost:5173',
        nodeVersion: process.version,
        platform: process.platform
      }
    };

    const reportPath = path.join(reportsDir, 'api_svelte_integration_report.json');
    fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
    console.log(`\n📄 Test report saved: ${reportPath}`);

    // Generate HTML report if possible
    try {
      const htmlReport = this.generateHtmlReport(report);
      const htmlReportPath = path.join(reportsDir, 'api_svelte_integration_report.html');
      fs.writeFileSync(htmlReportPath, htmlReport);
      console.log(`📄 HTML report saved: ${htmlReportPath}`);
    } catch (error) {
      console.log('⚠️  Could not generate HTML report:', error.message);
    }
  }

  /**
   * Generate HTML test report
   */
  generateHtmlReport(report) {
    const passed = report.summary.passed;
    const failed = report.summary.failed;
    const total = report.summary.total;
    const passRate = total > 0 ? ((passed / total) * 100).toFixed(1) : '0';

    return `
<!DOCTYPE html>
<html>
<head>
    <title>API-Svelte Integration Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #f5f5f5; padding: 20px; border-radius: 5px; }
        .summary { display: flex; gap: 20px; margin: 20px 0; }
        .metric { background: #e9f5e9; padding: 15px; border-radius: 5px; text-align: center; flex: 1; }
        .metric.failed { background: #ffe9e9; }
        .test-result { margin: 10px 0; padding: 10px; border-left: 4px solid #ddd; }
        .test-result.passed { border-left-color: #4caf50; background: #f9fff9; }
        .test-result.failed { border-left-color: #f44336; background: #fff9f9; }
        .error { color: #d32f2f; font-size: 0.9em; margin-top: 5px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🧪 API-Svelte Integration Test Report</h1>
        <p><strong>Generated:</strong> ${report.timestamp}</p>
        <p><strong>Duration:</strong> ${report.duration}</p>
        <p><strong>Environment:</strong> ${report.environment.apiBaseUrl} → ${report.environment.frontendBaseUrl}</p>
    </div>

    <div class="summary">
        <div class="metric">
            <h3>${total}</h3>
            <p>Total Tests</p>
        </div>
        <div class="metric">
            <h3>${passed}</h3>
            <p>Passed</p>
        </div>
        <div class="metric ${failed > 0 ? 'failed' : ''}">
            <h3>${failed}</h3>
            <p>Failed</p>
        </div>
        <div class="metric">
            <h3>${passRate}%</h3>
            <p>Pass Rate</p>
        </div>
    </div>

    <h2>Test Results</h2>
    ${Object.entries(report.results).map(([testName, result]) => `
        <div class="test-result ${result.success ? 'passed' : 'failed'}">
            <h4>${result.success ? '✅' : '❌'} ${result.description || testName}</h4>
            ${result.error ? `<div class="error">Error: ${result.error}</div>` : ''}
        </div>
    `).join('')}

    <h2>Environment Details</h2>
    <ul>
        <li><strong>API Base URL:</strong> ${report.environment.apiBaseUrl}</li>
        <li><strong>Frontend Base URL:</strong> ${report.environment.frontendBaseUrl}</li>
        <li><strong>Node Version:</strong> ${report.environment.nodeVersion}</li>
        <li><strong>Platform:</strong> ${report.environment.platform}</li>
    </ul>
</body>
</html>
    `.trim();
  }

  /**
   * Display usage information
   */
  displayUsage() {
    console.log(`
🧪 API-Svelte Integration Test Runner
════════════════════════════════════

This script tests the integration between your Svelte frontend and Rails API backend.

Prerequisites:
  1. Rails server running on port 3000 (or configured port)
     → bundle exec rails server

  2. Svelte dev server running on port 5173 (or configured port)
     → cd frontend && npm run dev

  3. Test database seeded with test data
     → RAILS_ENV=test bundle exec rails db:seed

Usage:
  node run_all.js                    Run all integration tests
  node run_all.js --help            Show this help

What gets tested:
  • CORS configuration
  • Authentication flow
  • JSON:API format compatibility
  • Error handling
  • Data pagination and filtering
  • Performance characteristics
  • File upload functionality (if implemented)
  • Real-time features (if implemented)

Output:
  • Console output with detailed results
  • JSON report: ../reports/api_svelte_integration_report.json
  • HTML report: ../reports/api_svelte_integration_report.html
`);
  }
}

// CLI handling
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.includes('--help') || args.includes('-h')) {
    const runner = new ApiSvelteTestRunner();
    runner.displayUsage();
    process.exit(0);
  }

  const runner = new ApiSvelteTestRunner();
  runner.runAllTests().then(success => {
    process.exit(success ? 0 : 1);
  }).catch(error => {
    console.error('❌ Test runner crashed:', error.message);
    console.error(error.stack);
    process.exit(1);
  });
}

module.exports = ApiSvelteTestRunner;
