#!/usr/bin/env node

/**
 * Test Router - Centralized Testing Hub for ProcStudio API
 *
 * This router provides a unified interface to run different types of tests:
 * - Unit tests (Rails RSpec tests)
 * - API tests (Direct Rails API testing)
 * - API-Svelte tests (Frontend-Backend integration)
 * - End-to-End tests (Full workflow testing)
 */

const { execSync, spawn } = require("child_process");
const fs = require("fs");
const path = require("path");
const readline = require("readline");

class TestRouter {
  constructor() {
    this.baseDir = path.resolve(__dirname, "..");
    this.testsDir = path.resolve(__dirname);
    this.config = this.loadConfig();
  }

  loadConfig() {
    const configPath = path.join(this.testsDir, "test_config.json");
    if (fs.existsSync(configPath)) {
      return JSON.parse(fs.readFileSync(configPath, "utf8"));
    }

    // Default configuration
    return {
      rails: {
        command: "bundle exec rspec",
        path: "spec",
      },
      api: {
        baseUrl: "http://localhost:3000/api/v1/",
        timeout: 30000,
        retries: 3,
      },
      frontend: {
        baseUrl: "http://localhost:5173",
        timeout: 30000,
      },
      e2e: {
        browser: "chromium",
        headless: true,
        timeout: 60000,
      },
    };
  }

  displayMenu() {
    console.log("\n🧪 ProcStudio Test Router");
    console.log("═══════════════════════════");
    console.log("1. Unit Tests (Rails RSpec)");
    console.log("2. API Tests (Direct Rails API)");
    console.log("3. API-Svelte Tests (Frontend-Backend Integration)");
    console.log("4. End-to-End Tests (Full Workflow)");
    console.log("5. Run All Tests");
    console.log("6. Test Configuration");
    console.log("7. Generate Test Reports");
    console.log("8. Exit");
    console.log("═══════════════════════════");
  }

  async getUserChoice() {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    return new Promise((resolve) => {
      rl.question("Select an option (1-8): ", (answer) => {
        rl.close();
        resolve(answer.trim());
      });
    });
  }

  async runUnitTests(specificTest = null) {
    console.log("\n🔧 Running Unit Tests (Rails RSpec)...");

    try {
      const command = specificTest
        ? `${this.config.rails.command} ${specificTest}`
        : this.config.rails.command;

      console.log(`Executing: ${command}`);

      const result = execSync(command, {
        cwd: this.baseDir,
        stdio: "inherit",
        encoding: "utf8",
      });

      console.log("✅ Unit tests completed successfully!");
      return true;
    } catch (error) {
      console.error("❌ Unit tests failed:", error.message);
      return false;
    }
  }

  async runApiTests(specificTest = null) {
    console.log("\n🌐 Running API Tests (Direct Rails API)...");

    try {
      // Check if Rails server is running
      await this.checkRailsServer();

      const testCommand = specificTest
        ? `node api/${specificTest}`
        : "node api/run_all.js";

      console.log(`Executing: ${testCommand}`);

      const result = execSync(testCommand, {
        cwd: this.testsDir,
        stdio: "inherit",
        encoding: "utf8",
      });

      console.log("✅ API tests completed successfully!");
      return true;
    } catch (error) {
      console.error("❌ API tests failed:", error.message);
      return false;
    }
  }

  async runApiSvelteTests(specificTest = null) {
    console.log("\n🔄 Running API-Svelte Integration Tests...");

    try {
      // Check if both Rails and Svelte servers are running
      await this.checkRailsServer();
      await this.checkSvelteServer();

      const testCommand = specificTest
        ? `node api_svelte/${specificTest}`
        : "node api_svelte/run_all.js";

      console.log(`Executing: ${testCommand}`);

      const result = execSync(testCommand, {
        cwd: this.testsDir,
        stdio: "inherit",
        encoding: "utf8",
      });

      console.log("✅ API-Svelte integration tests completed successfully!");
      return true;
    } catch (error) {
      console.error("❌ API-Svelte integration tests failed:", error.message);
      return false;
    }
  }

  async runE2ETests(specificTest = null) {
    console.log("\n🎭 Running End-to-End Tests...");

    try {
      // Check if all necessary servers are running
      await this.checkRailsServer();
      await this.checkSvelteServer();

      const testCommand = specificTest
        ? `npx playwright test ${specificTest}`
        : "npx playwright test";

      console.log(`Executing: ${testCommand}`);

      const result = execSync(testCommand, {
        cwd: path.join(this.testsDir, "e2e"),
        stdio: "inherit",
        encoding: "utf8",
      });

      console.log("✅ End-to-End tests completed successfully!");
      return true;
    } catch (error) {
      console.error("❌ End-to-End tests failed:", error.message);
      return false;
    }
  }

  async runAllTests() {
    console.log("\n🚀 Running All Test Suites...");

    const results = {
      unit: false,
      api: false,
      apiSvelte: false,
      e2e: false,
    };

    // Run tests in sequence
    results.unit = await this.runUnitTests();
    results.api = await this.runApiTests();
    results.apiSvelte = await this.runApiSvelteTests();
    results.e2e = await this.runE2ETests();

    // Display summary
    console.log("\n📊 Test Suite Summary");
    console.log("═══════════════════════");
    console.log(
      `Unit Tests:           ${results.unit ? "✅ PASSED" : "❌ FAILED"}`,
    );
    console.log(
      `API Tests:            ${results.api ? "✅ PASSED" : "❌ FAILED"}`,
    );
    console.log(
      `API-Svelte Tests:     ${results.apiSvelte ? "✅ PASSED" : "❌ FAILED"}`,
    );
    console.log(
      `End-to-End Tests:     ${results.e2e ? "✅ PASSED" : "❌ FAILED"}`,
    );

    const totalPassed = Object.values(results).filter((r) => r).length;
    const totalTests = Object.keys(results).length;

    console.log(`\nOverall: ${totalPassed}/${totalTests} test suites passed`);

    if (totalPassed === totalTests) {
      console.log("🎉 All tests passed!");
    } else {
      console.log("⚠️  Some tests failed. Check the output above for details.");
    }
  }

  async checkRailsServer() {
    try {
      const { default: fetch } = await import("node-fetch");
      const response = await fetch(`${this.config.api.baseUrl}/health`, {
        timeout: 5000,
      });

      if (!response.ok) {
        throw new Error(`Rails server returned ${response.status}`);
      }

      console.log("✅ Rails server is running");
      return true;
    } catch (error) {
      console.log("⚠️  Rails server not detected. Starting Rails server...");

      // Try to start Rails server
      try {
        spawn("bundle", ["exec", "rails", "server"], {
          cwd: this.baseDir,
          detached: true,
          stdio: "ignore",
        });

        // Wait a bit for server to start
        await new Promise((resolve) => setTimeout(resolve, 5000));

        return await this.checkRailsServer();
      } catch (startError) {
        throw new Error(
          "Could not start Rails server. Please start it manually: bundle exec rails server",
        );
      }
    }
  }

  async checkSvelteServer() {
    try {
      const { default: fetch } = await import("node-fetch");
      const response = await fetch(this.config.frontend.baseUrl, {
        timeout: 5000,
      });

      console.log("✅ Svelte server is running");
      return true;
    } catch (error) {
      console.log("⚠️  Svelte server not detected. Please start it manually:");
      console.log("   cd frontend && npm run dev");
      throw new Error(
        "Svelte server is required for integration and E2E tests",
      );
    }
  }

  displayConfiguration() {
    console.log("\n⚙️  Current Test Configuration");
    console.log("═══════════════════════════════");
    console.log(JSON.stringify(this.config, null, 2));
  }

  async generateReports() {
    console.log("\n📈 Generating Test Reports...");

    const reportPath = path.join(this.testsDir, "reports");
    if (!fs.existsSync(reportPath)) {
      fs.mkdirSync(reportPath, { recursive: true });
    }

    try {
      // Generate RSpec HTML report
      execSync(
        "bundle exec rspec --format html --out tests/reports/rspec_report.html",
        {
          cwd: this.baseDir,
        },
      );

      console.log(
        "✅ RSpec HTML report generated: tests/reports/rspec_report.html",
      );

      // Generate coverage report if SimpleCov is configured
      if (fs.existsSync(path.join(this.baseDir, "coverage"))) {
        console.log("✅ Coverage report available: coverage/index.html");
      }

      console.log("\n📊 Reports generated successfully!");
    } catch (error) {
      console.error("❌ Failed to generate reports:", error.message);
    }
  }

  async run() {
    while (true) {
      this.displayMenu();

      const choice = await this.getUserChoice();

      switch (choice) {
        case "1":
          await this.runUnitTests();
          break;
        case "2":
          await this.runApiTests();
          break;
        case "3":
          await this.runApiSvelteTests();
          break;
        case "4":
          await this.runE2ETests();
          break;
        case "5":
          await this.runAllTests();
          break;
        case "6":
          this.displayConfiguration();
          break;
        case "7":
          await this.generateReports();
          break;
        case "8":
          console.log("👋 Goodbye!");
          process.exit(0);
          break;
        default:
          console.log("❌ Invalid option. Please select 1-8.");
      }

      // Wait for user to press enter before showing menu again
      await new Promise((resolve) => {
        const rl = readline.createInterface({
          input: process.stdin,
          output: process.stdout,
        });
        rl.question("\nPress Enter to continue...", () => {
          rl.close();
          resolve();
        });
      });
    }
  }
}

// Handle CLI arguments for direct execution
if (require.main === module) {
  const args = process.argv.slice(2);
  const router = new TestRouter();

  if (args.length > 0) {
    const command = args[0];
    const testFile = args[1];

    switch (command) {
      case "unit":
        router.runUnitTests(testFile);
        break;
      case "api":
        router.runApiTests(testFile);
        break;
      case "api-svelte":
        router.runApiSvelteTests(testFile);
        break;
      case "e2e":
        router.runE2ETests(testFile);
        break;
      case "all":
        router.runAllTests();
        break;
      default:
        console.log(
          "Usage: node test_router.js [unit|api|api-svelte|e2e|all] [specific-test-file]",
        );
        process.exit(1);
    }
  } else {
    router.run();
  }
}

module.exports = TestRouter;
