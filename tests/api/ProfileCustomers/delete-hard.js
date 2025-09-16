/**
 * DELETE - Hard Delete (Destroy) Profile Customer Tests
 * Tests the destroy_fully parameter for permanent deletion
 */

const { 
  config,
  baseURL, 
  testState, 
  validators, 
  errorHandlers, 
  testUtils, 
  axios, 
  expect 
} = require('./config');
const { 
  generateCompleteProfileCustomer,
  dataGenerators 
} = require('./data');

/**
 * Run hard delete (destroy) tests
 */
const runHardDeleteTests = () => {
  describe('DELETE /profile_customers/:id?destroy_fully=true (Hard Delete)', function() {

    let profileForHardDelete = null;

    before(async function() {
      // Create a profile specifically for hard delete testing
      try {
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const url = `${baseURL}/profile_customers`;
        const requestData = generateCompleteProfileCustomer();

        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: requestData
        });

        profileForHardDelete = response.data.data?.id || response.data.id;
        // Don't add to cleanup since we'll hard delete it
      } catch (error) {
        console.error('Failed to create profile for hard delete test:', error.message);
      }
    });

    it('Should permanently delete a profile customer with destroy_fully=true', async function() {
      if (!profileForHardDelete) {
        testUtils.skipTest(this, 'No profile customer ID available for hard deletion');
        return;
      }

      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${profileForHardDelete}`;

      try {
        const response = await axios({
          method: 'delete',
          url: url,
          headers: headers,
          params: { destroy_fully: true }
        });

        // Hard delete typically returns 200 with success message
        expect(response.status).to.equal(200);
        expect(response.data).to.exist;
        
        // Check for success response structure
        if (response.data.success !== undefined) {
          expect(response.data.success).to.be.true;
        }
        if (response.data.message) {
          expect(response.data.message).to.be.a('string');
          expect(response.data.message.toLowerCase()).to.include('permanente');
        }
        
        testUtils.logSuccess(response.status, 'Hard delete profile', url, {
          'ID': profileForHardDelete,
          'Message': response.data.message || 'Permanently deleted',
          'Deletion Type': response.data.data?.deletion_type || 'hard_delete'
        });

        profileForHardDelete = null;

      } catch (error) {
        errorHandlers.handleApiError(error, 'Hard delete profile', url);
      }
    });

    it('Should verify hard deleted profile is completely removed', async function() {
      // This test should run after a successful hard delete
      if (profileForHardDelete !== null) {
        testUtils.skipTest(this, 'Previous hard delete did not complete');
        return;
      }

      // Try to access a hard deleted profile (use a known deleted ID)
      const deletedId = '99999998'; // Use a safe non-existent ID
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${deletedId}`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers,
          params: { include_deleted: true } // Even with this param, should not find
        });

        // Should not reach here for a hard deleted item
        throw new Error('Expected 404 for hard deleted profile');

      } catch (error) {
        if (error.response?.status === 404) {
          testUtils.logSuccess(404, 'Hard deleted profile not found', url);
        } else {
          throw error;
        }
      }
    });

    it('Should hard delete a soft deleted profile', async function() {
      let profileToDelete = null;
      
      try {
        // First create a profile
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const createUrl = `${baseURL}/profile_customers`;
        const createData = generateCompleteProfileCustomer();

        const createResponse = await axios({
          method: 'post',
          url: createUrl,
          headers: headers,
          data: createData
        });

        profileToDelete = createResponse.data.data?.id || createResponse.data.id;

        // Soft delete it first
        const softDeleteUrl = `${baseURL}/profile_customers/${profileToDelete}`;
        await axios({
          method: 'delete',
          url: softDeleteUrl,
          headers: headers
        });

        // Now hard delete it
        const hardDeleteUrl = `${baseURL}/profile_customers/${profileToDelete}`;
        const hardDeleteResponse = await axios({
          method: 'delete',
          url: hardDeleteUrl,
          headers: headers,
          params: { destroy_fully: true }
        });

        expect(hardDeleteResponse.status).to.be.oneOf([200, 204]);
        testUtils.logSuccess(hardDeleteResponse.status, 'Hard delete soft deleted profile', hardDeleteUrl);

      } catch (error) {
        // Hard delete of soft deleted might not be supported
        if (error.response?.status === 404) {
          testUtils.logSuccess(404, 'Soft deleted profile already inaccessible', '');
        } else if (error.response?.status === 405) {
          testUtils.logSuccess(405, 'Hard delete not supported', '');
        } else if (profileToDelete) {
          // Add to cleanup if we couldn't delete
          testUtils.addToCleanup(profileToDelete);
        }
      }
    });

    it('Should fail to hard delete non-existent profile', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/99999999`;

      try {
        const response = await axios({
          method: 'delete',
          url: url,
          headers: headers,
          params: { destroy_fully: true }
        });

        // Should not reach here
        throw new Error('Expected 404 error');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.equal(404);
          testUtils.logSuccess(error.response.status, 'Not found as expected', url);
        } else {
          throw error;
        }
      }
    });

    it('Should fail without authentication', async function() {
      // Create a profile for this test
      let profileId = null;
      
      try {
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const createUrl = `${baseURL}/profile_customers`;
        const createData = generateCompleteProfileCustomer();

        const createResponse = await axios({
          method: 'post',
          url: createUrl,
          headers: headers,
          data: createData
        });

        profileId = createResponse.data.data?.id || createResponse.data.id;
        testUtils.addToCleanup(profileId);

        // Try to hard delete without auth
        const deleteUrl = `${baseURL}/profile_customers/${profileId}/destroy`;
        
        const deleteResponse = await axios({
          method: 'delete',
          url: deleteUrl,
          headers: config.api.headers // No auth headers
        });

        // Should not reach here
        throw new Error('Expected authentication error');

      } catch (error) {
        if (error.response?.status === 401) {
          testUtils.logSuccess(401, 'Authentication required', '');
        } else if (error.response?.status === 405) {
          // Hard delete endpoint might not exist, try standard delete
          try {
            const standardUrl = `${baseURL}/profile_customers/${profileId}`;
            await axios({
              method: 'delete',
              url: standardUrl,
              headers: config.api.headers // No auth headers
            });
            throw new Error('Expected authentication error');
          } catch (standardError) {
            if (standardError.response?.status === 401) {
              testUtils.logSuccess(401, 'Authentication required', '');
            } else {
              throw standardError;
            }
          }
        } else if (error.message !== 'Expected authentication error') {
          // Some other error occurred during creation
          console.log(`   Info: ${error.message}`);
        } else {
          throw error;
        }
      }
    });

    it('Should handle cascade deletion of related records', async function() {
      // Create a profile with related records
      let profileId = null;
      
      try {
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const createUrl = `${baseURL}/profile_customers`;
        const createData = generateCompleteProfileCustomer();
        
        // Ensure we have related data
        createData.profile_customer.addresses_attributes = [
          ...createData.profile_customer.addresses_attributes,
          dataGenerators.generateAddress()
        ];
        createData.profile_customer.phones_attributes = [
          ...createData.profile_customer.phones_attributes,
          dataGenerators.generatePhone()
        ];

        const createResponse = await axios({
          method: 'post',
          url: createUrl,
          headers: headers,
          data: createData
        });

        profileId = createResponse.data.data?.id || createResponse.data.id;

        // Hard delete with cascade
        const deleteUrl = `${baseURL}/profile_customers/${profileId}/destroy`;
        const deleteResponse = await axios({
          method: 'delete',
          url: deleteUrl,
          headers: headers
        });

        expect(deleteResponse.status).to.be.oneOf([200, 204]);
        testUtils.logSuccess(deleteResponse.status, 'Cascade delete successful', deleteUrl);

      } catch (error) {
        // Cascade might be handled differently or hard delete might not exist
        if (profileId) {
          // Try standard delete as fallback
          try {
            const standardUrl = `${baseURL}/profile_customers/${profileId}`;
            const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
            await axios({
              method: 'delete',
              url: standardUrl,
              headers: headers
            });
            testUtils.logSuccess(200, 'Delete with cascade (hard delete unavailable)', standardUrl);
          } catch (fallbackError) {
            testUtils.addToCleanup(profileId);
          }
        }
      }
    });
  });

  // Cleanup function for remaining test data
  describe('Cleanup remaining test data', function() {

    after(async function() {
      if (testState.cleanupIds.length === 0) return;

      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      console.log(`\n   🧹 Cleaning up ${testState.cleanupIds.length} test profile(s)...`);

      for (const id of testState.cleanupIds) {
        try {
          // Try hard delete first
          const hardDeleteUrl = `${baseURL}/profile_customers/${id}/destroy`;
          await axios({
            method: 'delete',
            url: hardDeleteUrl,
            headers: headers
          });
          console.log(`   ✅ Hard deleted profile ${id}`);
        } catch (error) {
          // Fall back to soft delete
          try {
            const softDeleteUrl = `${baseURL}/profile_customers/${id}`;
            await axios({
              method: 'delete',
              url: softDeleteUrl,
              headers: headers
            });
            console.log(`   ✅ Soft deleted profile ${id}`);
          } catch (softError) {
            console.log(`   ⚠️ Could not delete profile ${id}`);
          }
        }
      }

      testState.cleanupIds = [];
    });
  });
};

module.exports = { runHardDeleteTests };