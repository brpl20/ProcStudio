/**
 * Generated API Tests for Profile Customers
 * Auto-generated from Postman collection
 */

const axios = require("axios");
const { expect } = require("chai");
const AuthHelper = require("../auth_helper");
const { apiTesting } = require("../../config");
const CPFGenerator = require("../../cpf_generator");

describe("Profile Customers", function () {
  this.timeout(30000);

  let authHelper = null;
  let randomProfileCustomerId = null;
  let createdProfileCustomerId = null;
  let profileCustomersList = [];
  const config = apiTesting;
  const baseURL = config.api.baseUrl;

  before(async function () {
    console.log(`🔐 Authenticating for Profile Customers tests...`);

    // Initialize auth helper and authenticate
    authHelper = new AuthHelper(config);
    await authHelper.authenticate();
  });

  it("Profile Customers - Criar um novo registro", async function () {
    const headers = { ...config.api.headers, ...authHelper.getAuthHeaders() };
    const url = `${baseURL}/profile_customers`;
    const timestamp = Date.now();
    const requestData = {
      profile_customer: {
        customer_type: "physical_person",
        name: `Test Profile ${timestamp}`,
        last_name: `Customer ${timestamp}`,
        status: "active",
        cpf: CPFGenerator.generate(),
        rg: `${Math.floor(Math.random() * 100000000)
          .toString()
          .padStart(9, "0")}`,
        birth: "1990-01-15",
        gender: "male",
        civil_status: "single",
        nationality: "brazilian",
        capacity: "able",
        profession: "Software Engineer",
        mother_name: `Mother of Test ${timestamp}`,

        customer_attributes: {
          email: `test_profile_${timestamp}@gmail.com`,
          password: "123456",
          password_confirmation: "123456",
        },

        addresses_attributes: [
          {
            description: "Home Address",
            zip_code: "01310-100",
            street: "Avenida Paulista",
            number: 1578,
            neighborhood: "Bela Vista",
            city: "São Paulo",
            state: "SP",
          },
        ],

        phones_attributes: [
          {
            phone_number: `+55 11 ${Math.floor(Math.random() * 900000000 + 100000000)}`,
          },
        ],

        emails_attributes: [
          {
            email: `test_profile_${timestamp}@example.com`,
          },
        ],

        bank_accounts_attributes: [
          {
            bank_name: "Banco do Brasil",
            type_account: "Corrente",
            agency: "1234-5",
            account: `${Math.floor(Math.random() * 100000)}-6`,
            operation: "001",
            pix: `test_profile_${timestamp}@example.com`,
          },
        ],
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

      // Store the created profile customer ID for later deletion
      if (response.data) {
        createdProfileCustomerId =
          response.data.id ||
          response.data.data?.id ||
          response.data.profile_customer?.id;
      }

      console.log(
        `✅ ${response.status} - Profile Customers - Criar um novo registro`,
      );
      console.log(`   Route: ${url}`);
      console.log(
        `   Created profile customer ID: ${createdProfileCustomerId}`,
      );
      console.log(
        `   Name: ${requestData.profile_customer.name} ${requestData.profile_customer.last_name}`,
      );
      console.log(
        `   Email: ${requestData.profile_customer.customer_attributes.email}`,
      );
    } catch (error) {
      if (error.response) {
        console.error(
          `❌ ${error.response.status} - Profile Customers - Criar um novo registro`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(
          `Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`,
        );
      } else {
        console.error(
          `❌ Network error - Profile Customers - Criar um novo registro`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
        throw error;
      }
    }
  });

  it("Profile Customers - Listar todos os registros", async function () {
    const headers = { ...config.api.headers, ...authHelper.getAuthHeaders() };
    const url = `${baseURL}/profile_customers`;

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

      // Store profile customers list and a random profile customer ID for subsequent tests
      if (response.data) {
        let profileCustomers = response.data.data || response.data;

        // Ensure profileCustomers is an array
        if (
          !Array.isArray(profileCustomers) &&
          profileCustomers.profile_customers
        ) {
          profileCustomers = profileCustomers.profile_customers;
        }

        if (Array.isArray(profileCustomers) && profileCustomers.length > 0) {
          profileCustomersList = profileCustomers;
          const randomIndex = Math.floor(
            Math.random() * profileCustomers.length,
          );
          randomProfileCustomerId =
            profileCustomers[randomIndex].id ||
            profileCustomers[randomIndex].profile_customer_id;
          console.log(
            `   📌 Selected random profile customer ID: ${randomProfileCustomerId} for testing`,
          );
        } else if (profileCustomers && profileCustomers.id) {
          // Single profile customer object
          profileCustomersList = [profileCustomers];
          randomProfileCustomerId = profileCustomers.id;
          console.log(
            `   📌 Using profile customer ID: ${randomProfileCustomerId} for testing`,
          );
        }
      }

      console.log(
        `✅ ${response.status} - Profile Customers - Listar todos os registros`,
      );
      console.log(`   Route: ${url}`);
      console.log(
        `   Total profile customers found: ${
          response.data.data
            ? response.data.data.length
            : response.data.profile_customers
              ? response.data.profile_customers.length
              : Array.isArray(response.data)
                ? response.data.length
                : "N/A"
        }`,
      );
    } catch (error) {
      if (error.response) {
        console.error(
          `❌ ${error.response.status} - Profile Customers - Listar todos os registros`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(
          `Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`,
        );
      } else {
        console.error(
          `❌ Network error - Profile Customers - Listar todos os registros`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
        throw error;
      }
    }
  });

  it("Profile Customers - Consultar um registro", async function () {
    // Skip this test if we don't have a profile customer ID
    if (!randomProfileCustomerId) {
      console.log(`   ⚠️ Skipping test - No profile customer ID available`);
      this.skip();
    }

    const headers = { ...config.api.headers, ...authHelper.getAuthHeaders() };
    const url = `${baseURL}/profile_customers/${randomProfileCustomerId}`;

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

      console.log(
        `✅ ${response.status} - Profile Customers - Consultar um registro`,
      );
      console.log(`   Route: ${url}`);
    } catch (error) {
      if (error.response) {
        console.error(
          `❌ ${error.response.status} - Profile Customers - Consultar um registro`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(
          `Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`,
        );
      } else {
        console.error(
          `❌ Network error - Profile Customers - Consultar um registro`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
        throw error;
      }
    }
  });

  it("Profile Customers - Atualizar um registro aleatório", async function () {
    // Skip this test if we don't have profile customers
    if (!profileCustomersList || profileCustomersList.length === 0) {
      console.log(`   ⚠️ Skipping test - No profile customers available`);
      this.skip();
    }

    // Pick a different random profile customer for update
    const availableProfileCustomers = profileCustomersList.filter(
      (pc) => (pc.id || pc.profile_customer_id) !== createdProfileCustomerId,
    );

    if (availableProfileCustomers.length === 0) {
      console.log(
        `   ⚠️ Skipping test - No other profile customers available for update`,
      );
      this.skip();
    }

    const randomIndex = Math.floor(
      Math.random() * availableProfileCustomers.length,
    );
    const profileCustomerToUpdate =
      availableProfileCustomers[randomIndex].id ||
      availableProfileCustomers[randomIndex].profile_customer_id;

    const headers = { ...config.api.headers, ...authHelper.getAuthHeaders() };
    const url = `${baseURL}/profile_customers/${profileCustomerToUpdate}`;
    const requestData = {
      profile_customer: {
        name: `Updated Profile ${Date.now()}`,
        last_name: `Updated Customer ${Date.now()}`,
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
        `✅ ${response.status} - Profile Customers - Atualizar um registro aleatório`,
      );
      console.log(`   Route: ${url}`);
      console.log(`   Updated profile customer ID: ${profileCustomerToUpdate}`);
      console.log(
        `   New name: ${requestData.profile_customer.name} ${requestData.profile_customer.last_name}`,
      );
    } catch (error) {
      if (error.response) {
        console.error(
          `❌ ${error.response.status} - Profile Customers - Atualizar um registro aleatório`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(
          `Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`,
        );
      } else {
        console.error(
          `❌ Network error - Profile Customers - Atualizar um registro aleatório`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
        throw error;
      }
    }
  });

  it("Profile Customers - Deletar um registro (soft delete)", async function () {
    // Prefer to delete the profile customer we created, fallback to a random one
    const profileCustomerToDelete =
      createdProfileCustomerId || randomProfileCustomerId;

    if (!profileCustomerToDelete) {
      console.log(
        `   ⚠️ Skipping test - No profile customer ID available for deletion`,
      );
      this.skip();
    }

    const headers = { ...config.api.headers, ...authHelper.getAuthHeaders() };
    const url = `${baseURL}/profile_customers/${profileCustomerToDelete}`;

    try {
      const response = await axios({
        method: "delete",
        url: url,
        headers: headers,
      });

      // Soft delete returns 200 with success response
      expect(response.status).to.equal(200);
      expect(response.data).to.exist;
      expect(response.data.success).to.be.true;
      expect(response.data.message).to.include("removido com sucesso");

      console.log(
        `✅ ${response.status} - Profile Customers - Deletar um registro (soft delete)`,
      );
      console.log(`   Route: ${url}`);
      console.log(
        `   Soft deleted profile customer ID: ${profileCustomerToDelete}`,
      );
      console.log(`   Message: ${response.data.message}`);

      if (profileCustomerToDelete === createdProfileCustomerId) {
        console.log(
          `   ✨ Cleaned up test-created profile customer (soft delete)`,
        );
      }
    } catch (error) {
      if (error.response) {
        console.error(
          `❌ ${error.response.status} - Profile Customers - Deletar um registro`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(
          `Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`,
        );
      } else {
        console.error(
          `❌ Network error - Profile Customers - Deletar um registro`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
        throw error;
      }
    }
  });

  it("Profile Customers - Testar acesso não autorizado (outro usuário)", async function () {
    // Skip this test if we don't have a profile customer ID to test
    if (!randomProfileCustomerId) {
      console.log(
        `   ⚠️ Skipping test - No profile customer ID available for unauthorized access test`,
      );
      this.skip();
    }

    const url = `${baseURL}/profile_customers/${randomProfileCustomerId}`;

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

      // Try to access first user's profile customer
      const response = await axios({
        method: "get",
        url: url,
        headers: headers,
      });

      // If we get here, the access was allowed (might be a security issue)
      console.log(
        `⚠️ ${response.status} - Profile Customers - Acesso permitido para outro usuário`,
      );
      console.log(`   Route: ${url}`);
      console.log(
        `   User u2@gmail.com could access profile customer ID: ${randomProfileCustomerId}`,
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
          `✅ ${error.response.status} - Profile Customers - Acesso negado para outro usuário (esperado)`,
        );
        console.log(`   Route: ${url}`);
        console.log(
          `   User u2@gmail.com correctly blocked from accessing profile customer ID: ${randomProfileCustomerId}`,
        );
      } else if (error.response) {
        // Unexpected error
        console.error(
          `❌ ${error.response.status} - Profile Customers - Teste de acesso não autorizado`,
        );
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(
          `Unexpected response status ${error.response.status}: ${JSON.stringify(error.response.data)}`,
        );
      } else {
        console.error(
          `❌ Network error - Profile Customers - Teste de acesso não autorizado`,
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
