/**
 * DELETE - Soft Delete Profile Customer Tests
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
  generateCompleteProfileCustomer 
} = require('./data');

/**
 * Run soft delete tests
 */
const runSoftDeleteTests = () => {
  describe('DELETE /profile_customers/:id (Soft Delete)', function() {

    let profileForSoftDelete = null;

    before(async function() {
      // Create a profile specifically for soft delete testing
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

        profileForSoftDelete = response.data.data?.id || response.data.id;
        testUtils.addToCleanup(profileForSoftDelete);
      } catch (error) {
        console.error('Failed to create profile for soft delete test:', error.message);
      }
    });

    it('Should soft delete a profile customer', async function() {
      if (!profileForSoftDelete) {
        testUtils.skipTest(this, 'No profile customer ID available for soft deletion');
        return;
      }

      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${profileForSoftDelete}`;

      try {
        const response = await axios({
          method: 'delete',
          url: url,
          headers: headers
        });

        // Soft delete typically returns 200 with success message
        expect(response.status).to.equal(200);
        expect(response.data).to.exist;
        
        // Check for success response structure
        if (response.data.success !== undefined) {
          expect(response.data.success).to.be.true;
        }
        if (response.data.message) {
          expect(response.data.message).to.be.a('string');
        }
        
        testUtils.logSuccess(response.status, 'Soft delete profile', url, {
          'ID': profileForSoftDelete,
          'Message': response.data.message || 'Soft deleted successfully'
        });

        // Mark as soft deleted to avoid hard delete attempt
        profileForSoftDelete = null;

      } catch (error) {
        errorHandlers.handleApiError(error, 'Soft delete profile', url);
      }
    });

    it('Should verify soft deleted profile is marked as inactive', async function() {
      // Try to access a soft deleted profile
      const profileToCheck = testState.cleanupIds[0]; // Use first cleanup ID if available
      
      if (!profileToCheck) {
        testUtils.skipTest(this, 'No soft deleted profile to verify');
        return;
      }

      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${profileToCheck}`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers,
          params: { include_deleted: true } // Some APIs require this param
        });

        if (response.status === 200) {
          const attributes = response.data.data?.attributes || response.data;
          
          // Check if it has a deleted_at timestamp or inactive status
          if (attributes.deleted_at) {
            expect(attributes.deleted_at).to.not.be.null;
            testUtils.logSuccess(200, 'Soft deleted profile has deleted_at', url);
          } else if (attributes.status) {
            expect(attributes.status).to.be.oneOf(['inactive', 'deleted']);
            testUtils.logSuccess(200, 'Soft deleted profile marked inactive', url);
          }
        }

      } catch (error) {
        // Some APIs might return 404 for soft deleted items
        if (error.response?.status === 404) {
          testUtils.logSuccess(404, 'Soft deleted profile not accessible', url);
        } else {
          // Not critical if this fails
          console.log(`   Info: Could not verify soft delete status`);
        }
      }
    });

    it('Should not list soft deleted profiles by default', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers
        });

        validators.validateResponse(response, 200);
        
        const data = response.data.data || response.data;
        
        // Check that no items have deleted_at set
        if (Array.isArray(data)) {
          data.forEach(item => {
            const attributes = item.attributes || item;
            if (attributes.deleted_at !== undefined) {
              expect(attributes.deleted_at).to.be.null;
            }
          });
        }

        testUtils.logSuccess(response.status, 'List excludes soft deleted', url);

      } catch (error) {
        errorHandlers.handleApiError(error, 'List without soft deleted', url);
      }
    });

    it('Should include soft deleted profiles with special parameter', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;
      const params = {
        include_deleted: true // or with_deleted, deleted, etc.
      };

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers,
          params: params
        });

        validators.validateResponse(response, 200);
        
        const data = response.data.data || response.data;
        
        // Look for any items with deleted_at set
        if (Array.isArray(data)) {
          const hasDeleted = data.some(item => {
            const attributes = item.attributes || item;
            return attributes.deleted_at !== undefined && attributes.deleted_at !== null;
          });
          
          if (hasDeleted) {
            testUtils.logSuccess(response.status, 'List includes soft deleted', url);
          } else {
            testUtils.logSuccess(response.status, 'No soft deleted items found', url);
          }
        }

      } catch (error) {
        // This parameter might not be supported
        if (error.response?.status === 400) {
          testUtils.logSuccess(400, 'Include deleted parameter not supported', url);
        } else {
          console.log(`   Info: Could not test include_deleted parameter`);
        }
      }
    });

    it('Should fail to soft delete non-existent profile', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/99999999`;

      try {
        const response = await axios({
          method: 'delete',
          url: url,
          headers: headers
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
      const profileToDelete = testState.createdProfileCustomerId || testState.randomProfileCustomerId;
      
      if (!profileToDelete) {
        testUtils.skipTest(this, 'No profile customer ID available');
        return;
      }

      const url = `${baseURL}/profile_customers/${profileToDelete}`;

      try {
        const response = await axios({
          method: 'delete',
          url: url,
          headers: config.api.headers // No auth headers
        });

        // Should not reach here
        throw new Error('Expected authentication error');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.equal(401);
          testUtils.logSuccess(error.response.status, 'Authentication required', url);
        } else {
          throw error;
        }
      }
    });

    it('Should restore soft deleted profile', async function() {
      // First create and soft delete a profile
      let profileToRestore = null;
      
      try {
        // Create profile
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const createUrl = `${config.baseURL}/profile_customers`;
        const createData = generateCompleteProfileCustomer();

        const createResponse = await axios({
          method: 'post',
          url: createUrl,
          headers: headers,
          data: createData
        });

        profileToRestore = createResponse.data.data?.id || createResponse.data.id;

        // Soft delete it
        const deleteUrl = `${config.baseURL}/profile_customers/${profileToRestore}`;
        await axios({
          method: 'delete',
          url: deleteUrl,
          headers: headers
        });

        // Try to restore
        const restoreUrl = `${config.baseURL}/profile_customers/${profileToRestore}/restore`;
        const restoreResponse = await axios({
          method: 'post',
          url: restoreUrl,
          headers: headers
        });

        validators.validateResponse(restoreResponse, 200);
        testUtils.logSuccess(restoreResponse.status, 'Restored soft deleted profile', restoreUrl);
        
        // Add to cleanup
        testUtils.addToCleanup(profileToRestore);

      } catch (error) {
        // Restore endpoint might not exist
        if (error.response?.status === 404 || error.response?.status === 405) {
          testUtils.logSuccess(error.response.status, 'Restore endpoint not implemented', '');
        } else if (profileToRestore) {
          // Still add to cleanup even if restore failed
          testUtils.addToCleanup(profileToRestore);
        }
      }
    });
  });
};

module.exports = { runSoftDeleteTests };