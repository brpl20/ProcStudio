#!/usr/bin/env node

/**
 * Rails Unit Test Runner
 *
 * This script provides a unified interface to run Rails RSpec tests
 * with additional features like test selection, reporting, and integration
 * with the main test router.
 */

const { spawn, execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

class RailsTestRunner {
  constructor() {
    this.projectRoot = path.resolve(__dirname, '../..');
    this.specDir = path.join(this.projectRoot, 'spec');
    this.config = this.loadConfig();
    this.results = {};
  }

  loadConfig() {
    const configPath = path.join(__dirname, '../test_config.json');
    if (fs.existsSync(configPath)) {
      return JSON.parse(fs.readFileSync(configPath, 'utf8'));
    }

    // Default Rails test configuration
    return {
      rails: {
        command: 'bundle exec rspec',
        path: 'spec',
        coverage: true,
        parallel: false,
        format: ['progress', 'html']
      }
    };
  }

  /**
   * Get available test categories
   */
  getTestCategories() {
    const categories = [];

    if (fs.existsSync(this.specDir)) {
      const items = fs.readdirSync(this.specDir, { withFileTypes: true });

      items.forEach(item => {
        if (item.isDirectory()) {
          const categoryPath = path.join(this.specDir, item.name);
          const testFiles = this.getTestFiles(categoryPath);

          if (testFiles.length > 0) {
            categories.push({
              name: item.name,
              path: categoryPath,
              count: testFiles.length,
              files: testFiles
            });
          }
        }
      });
    }

    return categories;
  }

  /**
   * Get test files in a directory
   */
  getTestFiles(directory, extension = '_spec.rb') {
    const files = [];

    if (!fs.existsSync(directory)) {
      return files;
    }

    const items = fs.readdirSync(directory, { withFileTypes: true });

    items.forEach(item => {
      if (item.isFile() && item.name.endsWith(extension)) {
        files.push(path.join(directory, item.name));
      } else if (item.isDirectory()) {
        files.push(...this.getTestFiles(path.join(directory, item.name), extension));
      }
    });

    return files;
  }

  /**
   * Display interactive menu
   */
  async displayMenu() {
    console.log('\n🔧 Rails Unit Test Runner');
    console.log('═══════════════════════════');
    console.log('1. Run All Tests');
    console.log('2. Run Tests by Category');
    console.log('3. Run Specific Test File');
    console.log('4. Run Tests with Coverage');
    console.log('5. Run Failed Tests Only');
    console.log('6. Show Test Statistics');
    console.log('7. Back to Main Menu');
    console.log('═══════════════════════════');

    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    return new Promise((resolve) => {
      rl.question('Select an option (1-7): ', (answer) => {
        rl.close();
        resolve(answer.trim());
      });
    });
  }

  /**
   * Run all RSpec tests
   */
  async runAllTests(options = {}) {
    console.log('\n🚀 Running All Rails Tests...');
    console.log('══════════════════════════════');

    const command = this.buildRspecCommand(null, options);

    try {
      console.log(`Executing: ${command}`);

      const startTime = Date.now();
      execSync(command, {
        cwd: this.projectRoot,
        stdio: 'inherit'
      });

      const duration = Date.now() - startTime;
      console.log(`\n✅ All tests completed successfully in ${(duration / 1000).toFixed(2)}s`);

      this.results.all = { success: true, duration };
      return true;
    } catch (error) {
      console.error('\n❌ Some tests failed');
      this.results.all = { success: false, error: error.message };
      return false;
    }
  }

  /**
   * Run tests by category
   */
  async runTestsByCategory() {
    const categories = this.getTestCategories();

    if (categories.length === 0) {
      console.log('❌ No test categories found in spec directory');
      return false;
    }

    console.log('\n📁 Available Test Categories:');
    categories.forEach((category, index) => {
      console.log(`${index + 1}. ${category.name} (${category.count} files)`);
    });

    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    const choice = await new Promise((resolve) => {
      rl.question('\nSelect category (number): ', (answer) => {
        rl.close();
        resolve(parseInt(answer.trim()) - 1);
      });
    });

    if (choice >= 0 && choice < categories.length) {
      const category = categories[choice];
      console.log(`\n🧪 Running ${category.name} tests...`);

      const command = this.buildRspecCommand(`spec/${category.name}`);

      try {
        execSync(command, {
          cwd: this.projectRoot,
          stdio: 'inherit'
        });

        console.log(`\n✅ ${category.name} tests completed successfully`);
        this.results[category.name] = { success: true };
        return true;
      } catch (error) {
        console.error(`\n❌ ${category.name} tests failed`);
        this.results[category.name] = { success: false };
        return false;
      }
    } else {
      console.log('❌ Invalid category selection');
      return false;
    }
  }

  /**
   * Run specific test file
   */
  async runSpecificTest() {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    const testPath = await new Promise((resolve) => {
      rl.question('Enter test file path (relative to spec/): ', (answer) => {
        rl.close();
        resolve(answer.trim());
      });
    });

    if (!testPath) {
      console.log('❌ No test file specified');
      return false;
    }

    const fullPath = path.join(this.specDir, testPath);

    if (!fs.existsSync(fullPath)) {
      console.log(`❌ Test file not found: ${fullPath}`);
      return false;
    }

    console.log(`\n🎯 Running specific test: ${testPath}`);

    const command = this.buildRspecCommand(`spec/${testPath}`);

    try {
      execSync(command, {
        cwd: this.projectRoot,
        stdio: 'inherit'
      });

      console.log('\n✅ Test completed successfully');
      return true;
    } catch (error) {
      console.error('\n❌ Test failed');
      return false;
    }
  }

  /**
   * Run tests with coverage report
   */
  async runWithCoverage() {
    console.log('\n📊 Running Tests with Coverage Report...');
    console.log('═══════════════════════════════════════');

    const command = this.buildRspecCommand(null, {
      coverage: true,
      format: 'html'
    });

    try {
      execSync(command, {
        cwd: this.projectRoot,
        stdio: 'inherit'
      });

      console.log('\n✅ Tests with coverage completed successfully');

      // Check if coverage report exists
      const coveragePath = path.join(this.projectRoot, 'coverage', 'index.html');
      if (fs.existsSync(coveragePath)) {
        console.log(`📈 Coverage report generated: ${coveragePath}`);
      }

      return true;
    } catch (error) {
      console.error('\n❌ Tests with coverage failed');
      return false;
    }
  }

  /**
   * Run only failed tests (requires previous failures)
   */
  async runFailedTests() {
    console.log('\n🔄 Running Failed Tests Only...');

    const command = this.buildRspecCommand(null, { onlyFailures: true });

    try {
      execSync(command, {
        cwd: this.projectRoot,
        stdio: 'inherit'
      });

      console.log('\n✅ Failed tests rerun completed');
      return true;
    } catch (error) {
      console.error('\n❌ Failed tests still failing');
      return false;
    }
  }

  /**
   * Show test statistics
   */
  showTestStatistics() {
    console.log('\n📈 Rails Test Statistics');
    console.log('═══════════════════════════');

    const categories = this.getTestCategories();
    let totalFiles = 0;

    categories.forEach(category => {
      console.log(`${category.name}: ${category.count} test files`);
      totalFiles += category.count;
    });

    console.log(`\nTotal: ${totalFiles} test files in ${categories.length} categories`);

    // Show recent results if available
    if (Object.keys(this.results).length > 0) {
      console.log('\n📊 Recent Test Results:');
      Object.entries(this.results).forEach(([test, result]) => {
        const status = result.success ? '✅ PASSED' : '❌ FAILED';
        const duration = result.duration ? ` (${(result.duration / 1000).toFixed(2)}s)` : '';
        console.log(`${test}: ${status}${duration}`);
      });
    }

    // Show coverage information if available
    const coveragePath = path.join(this.projectRoot, 'coverage', '.last_run.json');
    if (fs.existsSync(coveragePath)) {
      try {
        const coverageData = JSON.parse(fs.readFileSync(coveragePath, 'utf8'));
        console.log('\n📊 Last Coverage Report:');
        console.log(`Lines: ${coverageData.result?.line || 'N/A'}%`);
        console.log(`Branches: ${coverageData.result?.branch || 'N/A'}%`);
      } catch (error) {
        console.log('\n⚠️  Coverage data not available');
      }
    }
  }

  /**
   * Build RSpec command with options
   */
  buildRspecCommand(testPath = null, options = {}) {
    let command = this.config.rails.command;

    // Add test path if specified
    if (testPath) {
      command += ` ${testPath}`;
    }

    // Add format options
    if (options.format) {
      command += ` --format ${options.format}`;
    } else if (this.config.rails.format) {
      const formats = Array.isArray(this.config.rails.format)
        ? this.config.rails.format
        : [this.config.rails.format];

      formats.forEach(format => {
        command += ` --format ${format}`;
      });
    }

    // Add coverage option
    if (options.coverage && this.config.rails.coverage) {
      process.env.COVERAGE = 'true';
    }

    // Add HTML output for reports
    if (options.format === 'html' || this.config.rails.format?.includes('html')) {
      const reportsDir = path.join(__dirname, '../reports');
      if (!fs.existsSync(reportsDir)) {
        fs.mkdirSync(reportsDir, { recursive: true });
      }
      command += ` --out ${reportsDir}/rspec_report.html`;
    }

    // Add only failures option
    if (options.onlyFailures) {
      command += ' --only-failures';
    }

    // Add parallel execution if configured
    if (this.config.rails.parallel && !testPath) {
      command += ' --parallel';
    }

    return command;
  }

  /**
   * Interactive runner
   */
  async run() {
    while (true) {
      const choice = await this.displayMenu();

      switch (choice) {
        case '1':
          await this.runAllTests();
          break;
        case '2':
          await this.runTestsByCategory();
          break;
        case '3':
          await this.runSpecificTest();
          break;
        case '4':
          await this.runWithCoverage();
          break;
        case '5':
          await this.runFailedTests();
          break;
        case '6':
          this.showTestStatistics();
          break;
        case '7':
          return;
        default:
          console.log('❌ Invalid option. Please select 1-7.');
      }

      // Wait for user input before showing menu again
      const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
      });

      await new Promise((resolve) => {
        rl.question('\nPress Enter to continue...', () => {
          rl.close();
          resolve();
        });
      });
    }
  }
}

// CLI handling
if (require.main === module) {
  const args = process.argv.slice(2);
  const runner = new RailsTestRunner();

  if (args.length > 0) {
    const command = args[0];
    const testPath = args[1];

    switch (command) {
      case 'all':
        runner.runAllTests();
        break;
      case 'category':
        if (testPath) {
          runner.runAllTests({ testPath: `spec/${testPath}` });
        } else {
          runner.runTestsByCategory();
        }
        break;
      case 'file':
        if (testPath) {
          runner.runAllTests({ testPath: `spec/${testPath}` });
        } else {
          runner.runSpecificTest();
        }
        break;
      case 'coverage':
        runner.runWithCoverage();
        break;
      case 'failed':
        runner.runFailedTests();
        break;
      case 'stats':
        runner.showTestStatistics();
        break;
      default:
        console.log('Usage: node run_rails_tests.js [all|category|file|coverage|failed|stats] [test-path]');
        process.exit(1);
    }
  } else {
    runner.run();
  }
}

module.exports = RailsTestRunner;
