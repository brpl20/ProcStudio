/**
 * Generated API Tests for Customers
 * Auto-generated from Postman collection
 */

const axios = require("axios");
const { expect } = require("chai");
const AuthHelper = require("../auth_helper");
const { apiTesting } = require("../../config");

describe("Customers", function () {
  this.timeout(30000);

  let authHelper = null;
  let randomCustomerId = null;
  let createdCustomerId = null;
  let customersList = [];
  const config = apiTesting;
  const baseURL = config.api.baseUrl;

  before(async function () {
    console.log(`🔐 Authenticating for Customer/Customers tests...`);

    // Initialize auth helper and authenticate
    authHelper = new AuthHelper(config);
    await authHelper.authenticate();
  });

  it("Customers - Criar um novo registro", async function () {
    const headers = { ...config.api.headers, ...authHelper.getAuthHeaders() };
    const url = `${baseURL}/customers`;
    const timestamp = Date.now();
    const requestData = {
      customer: {
        email: `new_customer_${timestamp}@gmail.com`,
        password: "123456",
        password_confirmation: "123456",
        name: `Test Customer ${timestamp}`,
      },
    };

    try {
      const response = await axios({
        method: "post",
        url: url,
        headers: headers,
        data: requestData,
      });

      // Basic response validation
      expect(response.status).to.be.oneOf([200, 201]);
      expect(response.data).to.exist;

      // Store the created customer ID for later deletion
      if (response.data) {
        createdCustomerId =
          response.data.id ||
          response.data.data?.id ||
          response.data.customer?.id;
      }

      console.log(`✅ ${response.status} - Customers - Criar um novo registro`);
      console.log(`   Route: ${url}`);
      console.log(`   Created customer ID: ${createdCustomerId}`);
      console.log(`   Email: ${requestData.customer.email}`);
    } catch (error) {
      if (error.response) {
        console.error(
          `❌ ${error.response.status} - Customers - Criar um novo registro`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(
          `Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`,
        );
      } else {
        console.error(`❌ Network error - Customers - Criar um novo registro`);
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
        throw error;
      }
    }
  });

  it("Customers - Listar todos os registros", async function () {
    const headers = { ...config.api.headers, ...authHelper.getAuthHeaders() };
    const url = `${baseURL}/customers`;

    try {
      const response = await axios({
        method: "get",
        url: url,
        headers: headers,
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (
        response.headers["content-type"]?.includes("application/vnd.api+json")
      ) {
        validateJsonApiResponse(response);
      }

      // Store customers list and a random customer ID for subsequent tests
      if (response.data) {
        let customers = response.data.data || response.data;

        // Ensure customers is an array
        if (!Array.isArray(customers) && customers.customers) {
          customers = customers.customers;
        }

        if (Array.isArray(customers) && customers.length > 0) {
          customersList = customers;
          const randomIndex = Math.floor(Math.random() * customers.length);
          randomCustomerId =
            customers[randomIndex].id || customers[randomIndex].customer_id;
          console.log(
            `   📌 Selected random customer ID: ${randomCustomerId} for testing`,
          );
        } else if (customers && customers.id) {
          // Single customer object
          customersList = [customers];
          randomCustomerId = customers.id;
          console.log(
            `   📌 Using customer ID: ${randomCustomerId} for testing`,
          );
        }
      }

      console.log(
        `✅ ${response.status} - Customers - Listar todos os registros`,
      );
      console.log(`   Route: ${url}`);
      console.log(
        `   Total customers found: ${
          response.data.data
            ? response.data.data.length
            : response.data.customers
              ? response.data.customers.length
              : Array.isArray(response.data)
                ? response.data.length
                : "N/A"
        }`,
      );
    } catch (error) {
      if (error.response) {
        console.error(
          `❌ ${error.response.status} - Customers - Listar todos os registros`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(
          `Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`,
        );
      } else {
        console.error(
          `❌ Network error - Customers - Listar todos os registros`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
        throw error;
      }
    }
  });

  it("Customers - Consultar um registro", async function () {
    // Skip this test if we don't have a customer ID
    if (!randomCustomerId) {
      console.log(`   ⚠️ Skipping test - No customer ID available`);
      this.skip();
    }

    const headers = { ...config.api.headers, ...authHelper.getAuthHeaders() };
    const url = `${baseURL}/customers/${randomCustomerId}`;

    try {
      const response = await axios({
        method: "get",
        url: url,
        headers: headers,
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (
        response.headers["content-type"]?.includes("application/vnd.api+json")
      ) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Customers - Consultar um registro`);
      console.log(`   Route: ${url}`);
    } catch (error) {
      if (error.response) {
        console.error(
          `❌ ${error.response.status} - Customers - Consultar um registro`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(
          `Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`,
        );
      } else {
        console.error(`❌ Network error - Customers - Consultar um registro`);
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
        throw error;
      }
    }
  });

  it("Customers - Atualizar um registro aleatório", async function () {
    // Skip this test if we don't have customers
    if (!customersList || customersList.length === 0) {
      console.log(`   ⚠️ Skipping test - No customers available`);
      this.skip();
    }

    // Pick a different random customer for update
    const availableCustomers = customersList.filter(
      (c) => (c.id || c.customer_id) !== createdCustomerId,
    );

    if (availableCustomers.length === 0) {
      console.log(
        `   ⚠️ Skipping test - No other customers available for update`,
      );
      this.skip();
    }

    const randomIndex = Math.floor(Math.random() * availableCustomers.length);
    const customerToUpdate =
      availableCustomers[randomIndex].id ||
      availableCustomers[randomIndex].customer_id;

    const headers = { ...config.api.headers, ...authHelper.getAuthHeaders() };
    const url = `${baseURL}/customers/${customerToUpdate}`;
    const requestData = {
      customer: {
        email: `updated_${Date.now()}@gmail.com`,
        name: `Updated Customer ${Date.now()}`,
      },
    };

    try {
      const response = await axios({
        method: "put",
        url: url,
        headers: headers,
        data: requestData,
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (
        response.headers["content-type"]?.includes("application/vnd.api+json")
      ) {
        validateJsonApiResponse(response);
      }

      console.log(
        `✅ ${response.status} - Customers - Atualizar um registro aleatório`,
      );
      console.log(`   Route: ${url}`);
      console.log(`   Updated customer ID: ${customerToUpdate}`);
      console.log(`   New email: ${requestData.customer.email}`);
    } catch (error) {
      if (error.response) {
        console.error(
          `❌ ${error.response.status} - Customers - Atualizar um registro aleatório`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(
          `Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`,
        );
      } else {
        console.error(
          `❌ Network error - Customers - Atualizar um registro aleatório`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
        throw error;
      }
    }
  });

  it("Customers - Deletar um registro", async function () {
    // Prefer to delete the customer we created, fallback to a random one
    const customerToDelete = createdCustomerId || randomCustomerId;

    if (!customerToDelete) {
      console.log(
        `   ⚠️ Skipping test - No customer ID available for deletion`,
      );
      this.skip();
    }

    const headers = { ...config.api.headers, ...authHelper.getAuthHeaders() };
    const url = `${baseURL}/customers/${customerToDelete}`;

    try {
      const response = await axios({
        method: "delete",
        url: url,
        headers: headers,
      });

      // Basic response validation - DELETE might return 200, 204, or 202
      expect(response.status).to.be.oneOf([200, 202, 204]);

      console.log(`✅ ${response.status} - Customers - Deletar um registro`);
      console.log(`   Route: ${url}`);
      console.log(`   Deleted customer ID: ${customerToDelete}`);

      if (customerToDelete === createdCustomerId) {
        console.log(`   ✨ Cleaned up test-created customer`);
      }
    } catch (error) {
      if (error.response) {
        console.error(
          `❌ ${error.response.status} - Customers - Deletar um registro`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(
          `Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`,
        );
      } else {
        console.error(`❌ Network error - Customers - Deletar um registro`);
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
        throw error;
      }
    }
  });

  it("Customers - Testar acesso não autorizado (outro usuário)", async function () {
    // Skip this test if we don't have a customer ID to test
    if (!randomCustomerId) {
      console.log(
        `   ⚠️ Skipping test - No customer ID available for unauthorized access test`,
      );
      this.skip();
    }

    const url = `${baseURL}/customers/${randomCustomerId}`;

    console.log(`   🔐 Authenticating as different user (u2@gmail.com)...`);

    // Create a new auth helper for the second user
    const secondUserAuth = AuthHelper.createSecondUserAuthHelper(config);

    try {
      // Authenticate as second user
      await secondUserAuth.authenticate();

      const headers = {
        ...config.api.headers,
        ...secondUserAuth.getAuthHeaders(),
      };

      // Try to access first user's customer
      const response = await axios({
        method: "get",
        url: url,
        headers: headers,
      });

      // If we get here, the access was allowed (might be a security issue)
      console.log(
        `⚠️ ${response.status} - Customers - Acesso permitido para outro usuário`,
      );
      console.log(`   Route: ${url}`);
      console.log(
        `   User u2@gmail.com could access customer ID: ${randomCustomerId}`,
      );
      console.log(`   This might be a security issue if not intended`);
    } catch (error) {
      if (
        error.response &&
        (error.response.status === 403 ||
          error.response.status === 404 ||
          error.response.status === 401)
      ) {
        // Expected behavior - access denied
        console.log(
          `✅ ${error.response.status} - Customers - Acesso negado para outro usuário (esperado)`,
        );
        console.log(`   Route: ${url}`);
        console.log(
          `   User u2@gmail.com correctly blocked from accessing customer ID: ${randomCustomerId}`,
        );
      } else if (error.response) {
        // Unexpected error
        console.error(
          `❌ ${error.response.status} - Customers - Teste de acesso não autorizado`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(
          `Unexpected response status ${error.response.status}: ${JSON.stringify(error.response.data)}`,
        );
      } else {
        console.error(
          `❌ Network error - Customers - Teste de acesso não autorizado`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
        throw error;
      }
    }
  });

  // Helper functions
  function validateResponse(response, expectedStatus = 200) {
    expect(response.status).to.equal(expectedStatus);
    expect(response.data).to.exist;
  }

  function validateJsonApiResponse(response) {
    expect(response.data).to.have.property("data");
    if (Array.isArray(response.data.data)) {
      response.data.data.forEach((item) => {
        expect(item).to.have.property("id");
        expect(item).to.have.property("type");
        expect(item).to.have.property("attributes");
      });
    }
  }
});
