/**
 * Postman Collection Parser
 *
 * This module parses Postman collection.json files and converts them
 * into executable API tests for the test suite.
 */

const fs = require("fs");
const path = require("path");

class PostmanParser {
  constructor(collectionPath) {
    this.collectionPath = collectionPath;
    this.collection = null;
    this.variables = new Map();
    this.testSuites = [];
  }

  /**
   * Load and parse the Postman collection
   */
  loadCollection() {
    try {
      const collectionData = fs.readFileSync(this.collectionPath, "utf8");
      this.collection = JSON.parse(collectionData);
      this.extractVariables();
      return true;
    } catch (error) {
      console.error("Error loading collection:", error.message);
      return false;
    }
  }

  /**
   * Extract variables from the collection
   */
  extractVariables() {
    if (this.collection.variable) {
      this.collection.variable.forEach((variable) => {
        this.variables.set(variable.key, variable.value);
      });
    }

    // Set default variables if not present
    if (!this.variables.has("base_url")) {
      this.variables.set("base_url", "http://localhost:3000");
    }
  }

  /**
   * Replace variables in strings with their values
   */
  replaceVariables(str) {
    if (typeof str !== "string") return str;

    let result = str;
    this.variables.forEach((value, key) => {
      const regex = new RegExp(`{{${key}}}`, "g");
      result = result.replace(regex, value);
    });

    return result;
  }

  /**
   * Parse a single request item
   */
  parseRequest(item, parentName = "") {
    const testName = parentName ? `${parentName} - ${item.name}` : item.name;

    if (!item.request) {
      return null;
    }

    const request = item.request;
    const parsedRequest = {
      name: testName,
      method: request.method,
      url: this.parseUrl(request.url),
      cleanUrl: this.cleanUrlForTest(request.url),
      headers: this.parseHeaders(request.header),
      body: this.parseBody(request.body),
      auth: this.parseAuth(request.auth),
      description: request.description || "",
      tests: this.parseTests(item.event),
    };

    return parsedRequest;
  }

  /**
   * Parse URL object or string
   */
  parseUrl(url) {
    if (typeof url === "string") {
      return this.replaceVariables(url);
    }

    if (typeof url === "object" && url.raw) {
      let fullUrl = this.replaceVariables(url.raw);

      // Handle query parameters
      if (url.query && Array.isArray(url.query)) {
        const queryParams = url.query
          .filter((param) => param.key && param.value)
          .map((param) => `${param.key}=${encodeURIComponent(param.value)}`)
          .join("&");

        if (queryParams) {
          fullUrl += (fullUrl.includes("?") ? "&" : "?") + queryParams;
        }
      }

      return fullUrl;
    }

    return "";
  }

  /**
   * Parse headers array
   */
  parseHeaders(headers) {
    if (!Array.isArray(headers)) return {};

    const parsedHeaders = {};
    headers.forEach((header) => {
      if (header.key && header.value && !header.disabled) {
        parsedHeaders[header.key] = this.replaceVariables(header.value);
      }
    });

    return parsedHeaders;
  }

  /**
   * Parse request body
   */
  parseBody(body) {
    if (!body) return null;

    switch (body.mode) {
      case "raw":
        try {
          // Try to parse as JSON
          const jsonBody = JSON.parse(this.replaceVariables(body.raw));
          return {
            type: "json",
            data: jsonBody,
          };
        } catch {
          // If not JSON, return as raw text
          return {
            type: "raw",
            data: this.replaceVariables(body.raw),
          };
        }

      case "formdata":
        const formData = {};
        if (body.formdata) {
          body.formdata.forEach((item) => {
            if (item.key && item.value) {
              formData[item.key] = this.replaceVariables(item.value);
            }
          });
        }
        return {
          type: "form",
          data: formData,
        };

      case "urlencoded":
        const urlencoded = {};
        if (body.urlencoded) {
          body.urlencoded.forEach((item) => {
            if (item.key && item.value) {
              urlencoded[item.key] = this.replaceVariables(item.value);
            }
          });
        }
        return {
          type: "urlencoded",
          data: urlencoded,
        };

      default:
        return null;
    }
  }

  /**
   * Parse authentication
   */
  parseAuth(auth) {
    if (!auth || !auth.type) return null;

    switch (auth.type) {
      case "bearer":
        const bearerToken =
          auth.bearer?.find((item) => item.key === "token")?.value || "";
        return {
          type: "bearer",
          token: this.replaceVariables(bearerToken),
        };

      case "basic":
        return {
          type: "basic",
          username: this.replaceVariables(auth.basic?.username || ""),
          password: this.replaceVariables(auth.basic?.password || ""),
        };

      case "apikey":
        return {
          type: "apikey",
          key: auth.apikey?.key || "",
          value: this.replaceVariables(auth.apikey?.value || ""),
          in: auth.apikey?.in || "header",
        };

      default:
        return null;
    }
  }

  /**
   * Parse test scripts from events
   */
  parseTests(events) {
    if (!Array.isArray(events)) return [];

    const tests = [];
    events.forEach((event) => {
      if (event.listen === "test" && event.script && event.script.exec) {
        const testScript = Array.isArray(event.script.exec)
          ? event.script.exec.join("\n")
          : event.script.exec;

        tests.push({
          type: "postman",
          script: testScript,
        });
      }
    });

    return tests;
  }

  /**
   * Recursively parse collection items
   */
  parseItems(items, parentName = "") {
    const requests = [];

    items.forEach((item) => {
      const currentName = parentName ? `${parentName}/${item.name}` : item.name;

      if (item.item && Array.isArray(item.item)) {
        // This is a folder, recurse into it
        requests.push(...this.parseItems(item.item, currentName));
      } else if (item.request) {
        // This is a request
        const parsedRequest = this.parseRequest(item, parentName);
        if (parsedRequest) {
          parsedRequest.folder = parentName || "Root";
          requests.push(parsedRequest);
        }
      }
    });

    return requests;
  }

  /**
   * Generate test suites organized by folder
   */
  generateTestSuites() {
    if (!this.collection || !this.collection.item) {
      console.error("No collection loaded or invalid collection format");
      return [];
    }

    const allRequests = this.parseItems(this.collection.item);
    const suiteMap = new Map();

    // Group requests by folder
    allRequests.forEach((request) => {
      const folder = request.folder;
      if (!suiteMap.has(folder)) {
        suiteMap.set(folder, {
          name: folder,
          description: `Test suite for ${folder}`,
          requests: [],
        });
      }
      suiteMap.get(folder).requests.push(request);
    });

    this.testSuites = Array.from(suiteMap.values());
    return this.testSuites;
  }

  /**
   * Generate JavaScript test files
   */
  generateTestFiles(outputDir) {
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    this.testSuites.forEach((suite) => {
      const testContent = this.generateTestFileContent(suite);
      const fileName = `${suite.name.replace(/[^a-zA-Z0-9]/g, "_").toLowerCase()}_test.js`;
      const filePath = path.join(outputDir, fileName);

      fs.writeFileSync(filePath, testContent, "utf8");
      console.log(`Generated test file: ${filePath}`);
    });

    // Generate test runner
    const runnerContent = this.generateTestRunner();
    const runnerPath = path.join(outputDir, "run_all.js");
    fs.writeFileSync(runnerPath, runnerContent, "utf8");
    console.log(`Generated test runner: ${runnerPath}`);
  }

  /**
   * Generate content for a single test file
   */
  generateTestFileContent(suite) {
    return `/**
 * Generated API Tests for ${suite.name}
 * Auto-generated from Postman collection
 */

const axios = require('axios');
const { expect } = require('chai');
const fs = require('fs');
const path = require('path');

describe('${suite.name}', function() {
  this.timeout(30000);

  let authToken = null;
  let config = null;
  let baseURL = null;

  before(async function() {
    // Load test configuration
    config = JSON.parse(fs.readFileSync(path.join(__dirname, '../test_config.json'), 'utf8'));
    baseURL = config.api.baseUrl || 'http://localhost:3000';

    console.log(\`🔐 Authenticating for ${suite.name} tests...\`);

    // Setup authentication - WAIT for token
    if (config.api.auth && config.api.auth.testCredentials) {
      try {
        const authUrl = \`\${baseURL}\${config.api.auth.tokenEndpoint}\`;
        console.log(\`Authenticating at: \${authUrl}\`);

        const response = await axios.post(authUrl, config.api.auth.testCredentials, {
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          timeout: 10000
        });

        authToken = response.data.token || response.data.access_token || response.data.auth_token || response.data.data?.token || response.data.jwt;

        if (!authToken) {
          throw new Error('No token received from authentication response');
        }

        console.log(\`✅ Authentication successful for ${suite.name}\`);
      } catch (error) {
        console.error(\`❌ Authentication failed for ${suite.name}:\`, error.message);
        if (error.response) {
          console.error('Auth response status:', error.response.status);
          console.error('Auth response data:', error.response.data);
        }
        throw error; // Fail the tests if authentication fails
      }
    } else {
      console.warn('No authentication configuration found');
    }
  });

${suite.requests.map((request) => this.generateTestCase(request)).join("\n\n")}

  // Helper functions
  function getAuthHeaders() {
    const headers = {};
    if (authToken) {
      headers['Authorization'] = \`Bearer \${authToken}\`;
    }
    return headers;
  }

  function validateResponse(response, expectedStatus = 200) {
    expect(response.status).to.equal(expectedStatus);
    expect(response.data).to.exist;
  }

  function validateJsonApiResponse(response) {
    expect(response.data).to.have.property('data');
    if (Array.isArray(response.data.data)) {
      response.data.data.forEach(item => {
        expect(item).to.have.property('id');
        expect(item).to.have.property('type');
        expect(item).to.have.property('attributes');
      });
    }
  }
});
`;
  }

  /**
   * Generate a single test case
   */
  generateTestCase(request) {
    const method = request.method.toLowerCase();
    const safeName = request.name.replace(/['"]/g, "");

    let testBody = "";

    // Prepare headers
    let headersCode = `const headers = { ...config.api.headers, ...getAuthHeaders()`;
    if (Object.keys(request.headers).length > 0) {
      headersCode += `, ${JSON.stringify(request.headers, null, 4)}`;
    }
    headersCode += " };";

    // Prepare request data
    let requestDataCode = "";
    if (request.body && request.body.data) {
      if (request.body.type === "json") {
        requestDataCode = `const requestData = ${JSON.stringify(request.body.data, null, 4)};`;
      } else {
        requestDataCode = `const requestData = ${JSON.stringify(request.body.data, null, 4)};`;
      }
    }

    // Generate the actual test
    testBody = `  it('${safeName}', async function() {
    ${headersCode}
    ${requestDataCode}

    try {
      const response = await axios({
        method: '${method}',
        url: \`\${baseURL}${request.cleanUrl}\`,
        headers: headers${request.body ? ",\n        data: requestData" : ""}
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(\`✅ \${response.status} - ${safeName}\`);

    } catch (error) {
      if (error.response) {
        console.error(\`❌ \${error.response.status} - ${safeName}:\`, error.response.data);
        throw new Error(\`Request failed with status \${error.response.status}: \${JSON.stringify(error.response.data)}\`);
      } else {
        console.error(\`❌ Network error - ${safeName}:\`, error.message);
        throw error;
      }
    }
  });`;

    return testBody;
  }

  /**
   * Generate test runner script
   */
  generateTestRunner() {
    const testFiles = this.testSuites.map(
      (suite) =>
        `${suite.name.replace(/[^a-zA-Z0-9]/g, "_").toLowerCase()}_test.js`,
    );

    return `/**
 * API Test Runner
 * Runs all generated API tests
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

class ApiTestRunner {
  constructor() {
    this.testFiles = ${JSON.stringify(testFiles, null, 2)};
    this.results = {};
  }

  async runSingleTest(testFile) {
    return new Promise((resolve) => {
      console.log(\`\\n🧪 Running \${testFile}...\`);

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
        console.log(\`⚠️  Test file not found: \${testFile}\`);
        this.results[testFile] = false;
      }
    }

    this.displaySummary();
  }

  displaySummary() {
    console.log('\\n📊 API Test Results');
    console.log('═══════════════════');

    let passed = 0;
    let total = 0;

    Object.entries(this.results).forEach(([file, success]) => {
      const status = success ? '✅ PASSED' : '❌ FAILED';
      console.log(\`\${file}: \${status}\`);
      if (success) passed++;
      total++;
    });

    console.log(\`\\nOverall: \${passed}/\${total} test suites passed\`);

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
`;
  }

  /**
   * Get collection summary
   */
  getSummary() {
    if (!this.collection) return null;

    const summary = {
      name: this.collection.info?.name || "Unknown Collection",
      description: this.collection.info?.description || "",
      totalRequests: 0,
      totalFolders: 0,
      variables: Array.from(this.variables.keys()),
      testSuites: this.testSuites.length,
    };

    // Count requests and folders recursively
    const countItems = (items) => {
      items.forEach((item) => {
        if (item.item && Array.isArray(item.item)) {
          summary.totalFolders++;
          countItems(item.item);
        } else if (item.request) {
          summary.totalRequests++;
        }
      });
    };

    if (this.collection.item) {
      countItems(this.collection.item);
    }

    return summary;
  }

  /**
   * Clean URL for test generation by removing base URL patterns
   */
  cleanUrlForTest(urlObj) {
    let rawUrl;

    if (typeof urlObj === "string") {
      rawUrl = urlObj;
    } else if (urlObj && urlObj.raw) {
      rawUrl = urlObj.raw;
    } else {
      return "";
    }

    if (!rawUrl) return "";

    let cleanUrl = rawUrl;

    // Handle variable replacement first
    cleanUrl = this.replaceVariables(cleanUrl);

    // Remove various base URL patterns
    cleanUrl = cleanUrl.replace(/^.*?localhost:\d+/, "");
    cleanUrl = cleanUrl.replace(/^http:\/\/[^\/]+/, "");
    cleanUrl = cleanUrl.replace(/^https:\/\/[^\/]+/, "");

    // Ensure it starts with /
    if (cleanUrl && !cleanUrl.startsWith("/")) {
      cleanUrl = "/" + cleanUrl;
    }

    // Handle empty or root case
    if (!cleanUrl || cleanUrl === "/") {
      cleanUrl = "";
    }

    return cleanUrl;
  }
}

module.exports = PostmanParser;
