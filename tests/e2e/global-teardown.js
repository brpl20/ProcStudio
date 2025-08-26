/**
 * Playwright Global Teardown
 *
 * This file handles global teardown for E2E tests, including:
 * - Cleanup of test data
 * - Database cleanup
 * - File cleanup
 * - Report generation
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const axios = require('axios');

async function globalTeardown(config) {
  console.log('🧹 Starting E2E test environment teardown...');

  try {
    // 1. Generate final test reports
    await generateTestReports();

    // 2. Cleanup test data
    await cleanupTestData();

    // 3. Cleanup temporary files
    await cleanupTempFiles();

    // 4. Archive test artifacts
    await archiveTestArtifacts();

    console.log('✅ E2E test environment teardown completed');

  } catch (error) {
    console.error('❌ E2E teardown failed:', error.message);
    // Don't throw error in teardown to avoid masking test results
  }
}

/**
 * Generate comprehensive test reports
 */
async function generateTestReports() {
  console.log('📊 Generating test reports...');

  try {
    const reportsDir = path.join(__dirname, '../reports');

    if (!fs.existsSync(reportsDir)) {
      fs.mkdirSync(reportsDir, { recursive: true });
    }

    // Generate timestamp for this test run
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');

    // Collect test results from various sources
    const testResults = await collectTestResults(reportsDir);

    // Generate consolidated report
    const consolidatedReport = {
      testRun: {
        timestamp,
        environment: process.env.NODE_ENV || 'test',
        duration: testResults.totalDuration || 0,
        browsers: testResults.browsers || []
      },
      summary: {
        total: testResults.totalTests || 0,
        passed: testResults.passedTests || 0,
        failed: testResults.failedTests || 0,
        skipped: testResults.skippedTests || 0,
        flaky: testResults.flakyTests || 0
      },
      coverage: testResults.coverage || null,
      performance: testResults.performance || null,
      artifacts: {
        screenshots: testResults.screenshots || [],
        videos: testResults.videos || [],
        traces: testResults.traces || []
      }
    };

    // Save consolidated report
    const consolidatedReportPath = path.join(reportsDir, `e2e-consolidated-report-${timestamp}.json`);
    fs.writeFileSync(consolidatedReportPath, JSON.stringify(consolidatedReport, null, 2));

    // Generate HTML summary report
    const htmlReport = generateHtmlSummaryReport(consolidatedReport);
    const htmlReportPath = path.join(reportsDir, `e2e-summary-${timestamp}.html`);
    fs.writeFileSync(htmlReportPath, htmlReport);

    console.log(`✅ Test reports generated:`);
    console.log(`   JSON: ${consolidatedReportPath}`);
    console.log(`   HTML: ${htmlReportPath}`);

  } catch (error) {
    console.warn('⚠️  Report generation failed:', error.message);
  }
}

/**
 * Collect test results from various report files
 */
async function collectTestResults(reportsDir) {
  const results = {
    totalTests: 0,
    passedTests: 0,
    failedTests: 0,
    skippedTests: 0,
    flakyTests: 0,
    totalDuration: 0,
    browsers: [],
    screenshots: [],
    videos: [],
    traces: []
  };

  try {
    // Read Playwright JSON report if it exists
    const playwrightReportPath = path.join(reportsDir, 'e2e-results.json');
    if (fs.existsSync(playwrightReportPath)) {
      const playwrightReport = JSON.parse(fs.readFileSync(playwrightReportPath, 'utf8'));

      if (playwrightReport.stats) {
        results.totalTests = playwrightReport.stats.expected || 0;
        results.passedTests = playwrightReport.stats.passed || 0;
        results.failedTests = playwrightReport.stats.failed || 0;
        results.skippedTests = playwrightReport.stats.skipped || 0;
        results.flakyTests = playwrightReport.stats.flaky || 0;
      }

      if (playwrightReport.config && playwrightReport.config.projects) {
        results.browsers = playwrightReport.config.projects.map(p => p.name);
      }
    }

    // Collect artifact files
    const artifactsDir = path.join(__dirname, 'test-results');
    if (fs.existsSync(artifactsDir)) {
      const collectArtifacts = (dir, filePattern, type) => {
        try {
          const files = fs.readdirSync(dir, { recursive: true });
          return files.filter(file => file.toString().match(filePattern))
                     .map(file => ({ file: file.toString(), type, path: path.join(dir, file.toString()) }));
        } catch (error) {
          return [];
        }
      };

      results.screenshots = collectArtifacts(artifactsDir, /\.png$/, 'screenshot');
      results.videos = collectArtifacts(artifactsDir, /\.webm$/, 'video');
      results.traces = collectArtifacts(artifactsDir, /\.zip$/, 'trace');
    }

  } catch (error) {
    console.warn('⚠️  Could not collect test results:', error.message);
  }

  return results;
}

/**
 * Generate HTML summary report
 */
function generateHtmlSummaryReport(report) {
  const passRate = report.summary.total > 0
    ? ((report.summary.passed / report.summary.total) * 100).toFixed(1)
    : '0';

  return `
<!DOCTYPE html>
<html>
<head>
    <title>E2E Test Summary Report</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 40px; padding-bottom: 20px; border-bottom: 2px solid #eee; }
        .metrics { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 30px 0; }
        .metric { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px; text-align: center; }
        .metric.passed { background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%); }
        .metric.failed { background: linear-gradient(135deg, #f44336 0%, #da190b 100%); }
        .metric.skipped { background: linear-gradient(135deg, #ff9800 0%, #f57c00 100%); }
        .metric h3 { margin: 0 0 10px 0; font-size: 2.5em; font-weight: bold; }
        .metric p { margin: 0; font-size: 1.1em; opacity: 0.9; }
        .section { margin: 30px 0; }
        .section h2 { color: #333; border-bottom: 2px solid #667eea; padding-bottom: 10px; }
        .browsers { display: flex; flex-wrap: wrap; gap: 10px; margin: 15px 0; }
        .browser { background: #e3f2fd; padding: 8px 16px; border-radius: 20px; font-size: 0.9em; }
        .artifacts { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .artifact-group { background: #f8f9fa; padding: 20px; border-radius: 8px; }
        .artifact-list { max-height: 200px; overflow-y: auto; }
        .artifact-item { padding: 5px 0; font-size: 0.9em; color: #666; }
        .timestamp { color: #666; font-size: 0.9em; }
        .pass-rate { font-size: 3em; font-weight: bold; color: ${report.summary.failed > 0 ? '#f44336' : '#4CAF50'}; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎭 End-to-End Test Summary</h1>
            <p class="timestamp">Generated: ${report.testRun.timestamp}</p>
            <p class="timestamp">Environment: ${report.testRun.environment}</p>
            <div class="pass-rate">${passRate}%</div>
            <p>Pass Rate</p>
        </div>

        <div class="metrics">
            <div class="metric">
                <h3>${report.summary.total}</h3>
                <p>Total Tests</p>
            </div>
            <div class="metric passed">
                <h3>${report.summary.passed}</h3>
                <p>Passed</p>
            </div>
            <div class="metric failed">
                <h3>${report.summary.failed}</h3>
                <p>Failed</p>
            </div>
            <div class="metric skipped">
                <h3>${report.summary.skipped}</h3>
                <p>Skipped</p>
            </div>
        </div>

        <div class="section">
            <h2>🌐 Test Environment</h2>
            <p><strong>Browsers:</strong></p>
            <div class="browsers">
                ${report.testRun.browsers.map(browser => `<span class="browser">${browser}</span>`).join('')}
            </div>
            <p><strong>Duration:</strong> ${Math.round(report.testRun.duration / 1000)}s</p>
        </div>

        <div class="section">
            <h2>📎 Test Artifacts</h2>
            <div class="artifacts">
                <div class="artifact-group">
                    <h3>📸 Screenshots (${report.artifacts.screenshots.length})</h3>
                    <div class="artifact-list">
                        ${report.artifacts.screenshots.map(item =>
                            `<div class="artifact-item">📸 ${path.basename(item.file)}</div>`
                        ).join('') || '<p>No screenshots captured</p>'}
                    </div>
                </div>
                <div class="artifact-group">
                    <h3>🎥 Videos (${report.artifacts.videos.length})</h3>
                    <div class="artifact-list">
                        ${report.artifacts.videos.map(item =>
                            `<div class="artifact-item">🎥 ${path.basename(item.file)}</div>`
                        ).join('') || '<p>No videos recorded</p>'}
                    </div>
                </div>
                <div class="artifact-group">
                    <h3>🔍 Traces (${report.artifacts.traces.length})</h3>
                    <div class="artifact-list">
                        ${report.artifacts.traces.map(item =>
                            `<div class="artifact-item">🔍 ${path.basename(item.file)}</div>`
                        ).join('') || '<p>No traces captured</p>'}
                    </div>
                </div>
            </div>
        </div>

        <div class="section">
            <h2>📋 Test Results</h2>
            <p><strong>Overall Status:</strong> ${report.summary.failed === 0 ? '✅ All tests passed' : '❌ Some tests failed'}</p>
            ${report.summary.flaky > 0 ? `<p><strong>Flaky Tests:</strong> ${report.summary.flaky} (consider reviewing these)</p>` : ''}

            <h3>Next Steps:</h3>
            <ul>
                ${report.summary.failed > 0 ? '<li>❌ Review failed tests and fix issues before deploying</li>' : ''}
                ${report.summary.flaky > 0 ? '<li>⚠️  Investigate flaky tests for stability improvements</li>' : ''}
                <li>📊 Review detailed HTML report for more insights</li>
                <li>🔍 Check traces and videos for failed tests</li>
                ${report.summary.failed === 0 ? '<li>🚀 All tests passed - ready for deployment!</li>' : ''}
            </ul>
        </div>
    </div>
</body>
</html>
  `.trim();
}

/**
 * Cleanup test data from database
 */
async function cleanupTestData() {
  console.log('🗄️  Cleaning up test data...');

  try {
    // Clean up test-specific data
    const apiUrl = process.env.BASE_URL || 'http://localhost:3000';

    // Try to authenticate and clean up test data
    try {
      const authResponse = await axios.post(`${apiUrl}/auth/login`, {
        email: 'admin@e2etest.procstudio.com',
        password: 'E2ETestPass123!'
      }, {
        headers: { 'Content-Type': 'application/json' },
        timeout: 5000
      });

      const token = authResponse.data.token || authResponse.data.access_token;
      const authHeaders = {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      };

      // Clean up test resources
      const cleanupEndpoints = [
        '/test-cleanup/users',
        '/test-cleanup/cases',
        '/test-cleanup/documents',
        '/test-cleanup/all'
      ];

      for (const endpoint of cleanupEndpoints) {
        try {
          await axios.delete(`${apiUrl}${endpoint}`, {
            headers: authHeaders,
            timeout: 10000
          });
        } catch (error) {
          // Ignore 404s - cleanup endpoint might not exist
          if (error.response?.status !== 404) {
            console.warn(`⚠️  Cleanup failed for ${endpoint}:`, error.message);
          }
        }
      }

    } catch (error) {
      console.warn('⚠️  API-based cleanup failed, trying database cleanup...');

      // Fallback to direct database cleanup
      const projectRoot = path.resolve(__dirname, '../..');
      try {
        execSync('RAILS_ENV=test bundle exec rails runner "User.where(email: [\'admin@e2etest.procstudio.com\', \'user@e2etest.procstudio.com\', \'lawyer@e2etest.procstudio.com\']).destroy_all"', {
          cwd: projectRoot,
          stdio: 'pipe',
          env: { ...process.env, RAILS_ENV: 'test' }
        });
        console.log('✅ Database cleanup completed');
      } catch (dbError) {
        console.warn('⚠️  Database cleanup failed:', dbError.message);
      }
    }

  } catch (error) {
    console.warn('⚠️  Test data cleanup failed:', error.message);
  }
}

/**
 * Cleanup temporary files and test artifacts
 */
async function cleanupTempFiles() {
  console.log('📁 Cleaning up temporary files...');

  try {
    const filesToClean = [
      path.join(__dirname, 'test-users.json'),
      path.join(__dirname, 'test-data.json'),
      path.join(__dirname, 'storage-states')
    ];

    for (const filePath of filesToClean) {
      try {
        if (fs.existsSync(filePath)) {
          if (fs.lstatSync(filePath).isDirectory()) {
            fs.rmSync(filePath, { recursive: true, force: true });
          } else {
            fs.unlinkSync(filePath);
          }
          console.log(`🗑️  Removed: ${filePath}`);
        }
      } catch (error) {
        console.warn(`⚠️  Could not remove ${filePath}:`, error.message);
      }
    }

  } catch (error) {
    console.warn('⚠️  Temp file cleanup failed:', error.message);
  }
}

/**
 * Archive test artifacts for later analysis
 */
async function archiveTestArtifacts() {
  console.log('📦 Archiving test artifacts...');

  try {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const archiveDir = path.join(__dirname, '../reports', 'archives');
    const currentArchive = path.join(archiveDir, `e2e-run-${timestamp}`);

    if (!fs.existsSync(archiveDir)) {
      fs.mkdirSync(archiveDir, { recursive: true });
    }

    if (!fs.existsSync(currentArchive)) {
      fs.mkdirSync(currentArchive, { recursive: true });
    }

    // Archive test results
    const testResultsDir = path.join(__dirname, 'test-results');
    if (fs.existsSync(testResultsDir)) {
      const { execSync } = require('child_process');
      try {
        execSync(`cp -r "${testResultsDir}" "${path.join(currentArchive, 'test-results')}"`, {
          stdio: 'pipe'
        });
        console.log(`📦 Archived test results to: ${currentArchive}`);
      } catch (error) {
        console.warn('⚠️  Could not archive test results:', error.message);
      }
    }

    // Keep only the last 5 archives to prevent disk space issues
    try {
      const archives = fs.readdirSync(archiveDir)
        .filter(name => name.startsWith('e2e-run-'))
        .sort()
        .reverse();

      if (archives.length > 5) {
        for (let i = 5; i < archives.length; i++) {
          const oldArchive = path.join(archiveDir, archives[i]);
          fs.rmSync(oldArchive, { recursive: true, force: true });
          console.log(`🗑️  Removed old archive: ${archives[i]}`);
        }
      }
    } catch (error) {
      console.warn('⚠️  Archive cleanup failed:', error.message);
    }

  } catch (error) {
    console.warn('⚠️  Artifact archiving failed:', error.message);
  }
}

module.exports = globalTeardown;
