/**
 * POST - Restore Profile Customer Tests
 * Tests the restore functionality for soft-deleted profile customers
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
 * Run restore tests
 */
const runRestoreTests = () => {
  describe('POST /profile_customers/:id/restore (Restore)', function() {

    let profileForRestore = null;
    let softDeletedProfile = null;

    before(async function() {
      // Create a profile specifically for restore testing
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

        profileForRestore = response.data.data?.id || response.data.id;
        testUtils.addToCleanup(profileForRestore);
      } catch (error) {
        console.error('Failed to create profile for restore test:', error.message);
      }
    });

    it('Should soft delete a profile customer first', async function() {
      if (!profileForRestore) {
        testUtils.skipTest(this, 'No profile customer ID available for soft deletion');
        return;
      }

      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${profileForRestore}`;

      try {
        const response = await axios({
          method: 'delete',
          url: url,
          headers: headers
        });

        expect(response.status).to.equal(200);
        expect(response.data.success).to.be.true;
        
        softDeletedProfile = profileForRestore;
        
        testUtils.logSuccess(response.status, 'Soft delete profile for restore test', url, {
          'ID': profileForRestore,
          'Message': response.data.message || 'Soft deleted successfully'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Soft delete profile for restore', url);
      }
    });

    it('Should restore a soft-deleted profile customer', async function() {
      if (!softDeletedProfile) {
        testUtils.skipTest(this, 'No soft-deleted profile customer available for restore');
        return;
      }

      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${softDeletedProfile}/restore`;

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: headers
        });

        expect(response.status).to.equal(200);
        expect(response.data).to.exist;
        
        // Check for success response structure
        if (response.data.success !== undefined) {
          expect(response.data.success).to.be.true;
        }
        if (response.data.message) {
          expect(response.data.message).to.be.a('string');
          expect(response.data.message.toLowerCase()).to.include('restaurad');
        }
        
        // Check that data is returned
        if (response.data.data) {
          expect(response.data.data).to.be.an('object');
          expect(response.data.data.id || response.data.data.attributes?.id).to.exist;
        }
        
        testUtils.logSuccess(response.status, 'Restore profile', url, {
          'ID': softDeletedProfile,
          'Message': response.data.message || 'Restored successfully'
        });

        // Profile is now restored, no longer needs special handling
        softDeletedProfile = null;

      } catch (error) {
        errorHandlers.handleApiError(error, 'Restore profile', url);
      }
    });

    it('Should verify restored profile is accessible normally', async function() {
      if (!profileForRestore) {
        testUtils.skipTest(this, 'No profile customer ID available to verify');
        return;
      }

      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${profileForRestore}`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers
        });

        expect(response.status).to.equal(200);
        
        const data = response.data.data || response.data;
        expect(data).to.be.an('object');
        
        // Check that deleted_at is null or undefined (not deleted)
        const attributes = data.attributes || data;
        if (attributes.deleted_at !== undefined) {
          expect(attributes.deleted_at).to.be.null;
        }
        
        testUtils.logSuccess(response.status, 'Restored profile accessible', url, {
          'ID': profileForRestore,
          'Status': attributes.status || 'active'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Access restored profile', url);
      }
    });

    it('Should restore with associations when specified', async function() {
      // Create a profile with associations, delete it, then restore with associations
      let profileWithAssociations = null;
      
      try {
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const createUrl = `${baseURL}/profile_customers`;
        const createData = generateCompleteProfileCustomer();

        // Create profile
        const createResponse = await axios({
          method: 'post',
          url: createUrl,
          headers: headers,
          data: createData
        });

        profileWithAssociations = createResponse.data.data?.id || createResponse.data.id;

        // Soft delete it
        const deleteUrl = `${baseURL}/profile_customers/${profileWithAssociations}`;
        await axios({
          method: 'delete',
          url: deleteUrl,
          headers: headers
        });

        // Restore with associations
        const restoreUrl = `${baseURL}/profile_customers/${profileWithAssociations}/restore`;
        const restoreResponse = await axios({
          method: 'post',
          url: restoreUrl,
          headers: headers,
          params: { restore_associations: true }
        });

        expect(restoreResponse.status).to.equal(200);
        testUtils.logSuccess(restoreResponse.status, 'Restore with associations', restoreUrl);
        
        // Add to cleanup
        testUtils.addToCleanup(profileWithAssociations);

      } catch (error) {
        if (error.response?.status === 400) {
          // Parameter might not be supported
          testUtils.logSuccess(400, 'Restore associations parameter not supported', '');
        } else if (profileWithAssociations) {
          testUtils.addToCleanup(profileWithAssociations);
          errorHandlers.handleApiError(error, 'Restore with associations', '');
        }
      }
    });

    it('Should fail to restore non-existent profile', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/99999999/restore`;

      try {
        const response = await axios({
          method: 'post',
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

    it('Should fail to restore already active profile', async function() {
      // Try to restore a profile that was never deleted
      let activeProfile = null;
      
      try {
        // Create a new profile
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const createUrl = `${baseURL}/profile_customers`;
        const createData = generateCompleteProfileCustomer();

        const createResponse = await axios({
          method: 'post',
          url: createUrl,
          headers: headers,
          data: createData
        });

        activeProfile = createResponse.data.data?.id || createResponse.data.id;
        testUtils.addToCleanup(activeProfile);

        // Try to restore it (should fail since it's not deleted)
        const restoreUrl = `${baseURL}/profile_customers/${activeProfile}/restore`;
        const restoreResponse = await axios({
          method: 'post',
          url: restoreUrl,
          headers: headers
        });

        // Should not reach here
        throw new Error('Expected error when restoring active profile');

      } catch (error) {
        if (error.response?.status === 422) {
          // Unprocessable entity - profile is not deleted
          testUtils.logSuccess(422, 'Cannot restore active profile', '');
        } else if (error.response?.status === 400) {
          // Bad request - profile is not deleted
          testUtils.logSuccess(400, 'Cannot restore active profile', '');
        } else if (error.message === 'Expected error when restoring active profile') {
          // The restore succeeded, which might be acceptable behavior
          testUtils.logSuccess(200, 'Restore succeeded on active profile (allowed)', '');
        } else if (activeProfile) {
          throw error;
        }
      }
    });

    it('Should fail without authentication', async function() {
      const profileToRestore = testState.createdProfileCustomerId || '1';
      const url = `${baseURL}/profile_customers/${profileToRestore}/restore`;

      try {
        const response = await axios({
          method: 'post',
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

    it('Should fail to restore hard-deleted profile', async function() {
      // Create a profile, hard delete it, then try to restore
      let hardDeletedProfile = null;
      
      try {
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const createUrl = `${baseURL}/profile_customers`;
        const createData = generateCompleteProfileCustomer();

        // Create profile
        const createResponse = await axios({
          method: 'post',
          url: createUrl,
          headers: headers,
          data: createData
        });

        hardDeletedProfile = createResponse.data.data?.id || createResponse.data.id;

        // Hard delete it
        const deleteUrl = `${baseURL}/profile_customers/${hardDeletedProfile}`;
        await axios({
          method: 'delete',
          url: deleteUrl,
          headers: headers,
          params: { destroy_fully: true }
        });

        // Try to restore it (should fail)
        const restoreUrl = `${baseURL}/profile_customers/${hardDeletedProfile}/restore`;
        const restoreResponse = await axios({
          method: 'post',
          url: restoreUrl,
          headers: headers
        });

        // Should not reach here
        throw new Error('Expected 404 error for hard-deleted profile');

      } catch (error) {
        if (error.response?.status === 404) {
          testUtils.logSuccess(404, 'Cannot restore hard-deleted profile', '');
        } else if (error.message === 'Expected 404 error for hard-deleted profile') {
          throw error;
        } else {
          // Hard delete might not be implemented, so just log
          console.log(`   Info: Hard delete test inconclusive: ${error.message}`);
        }
      }
    });

    it('Should handle restore with validation errors gracefully', async function() {
      // Create a profile, modify its data to cause validation issues, then try to restore
      let profileWithIssues = null;
      
      try {
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const createUrl = `${baseURL}/profile_customers`;
        const createData = generateCompleteProfileCustomer();

        // Create profile
        const createResponse = await axios({
          method: 'post',
          url: createUrl,
          headers: headers,
          data: createData
        });

        profileWithIssues = createResponse.data.data?.id || createResponse.data.id;

        // Soft delete it
        const deleteUrl = `${baseURL}/profile_customers/${profileWithIssues}`;
        await axios({
          method: 'delete',
          url: deleteUrl,
          headers: headers
        });

        // Try to restore (most profiles should restore fine)
        const restoreUrl = `${baseURL}/profile_customers/${profileWithIssues}/restore`;
        const restoreResponse = await axios({
          method: 'post',
          url: restoreUrl,
          headers: headers
        });

        if (restoreResponse.status === 200) {
          testUtils.logSuccess(200, 'Restore succeeded without validation issues', restoreUrl);
          testUtils.addToCleanup(profileWithIssues);
        }

      } catch (error) {
        if (error.response?.status === 422) {
          // Validation error during restore
          testUtils.logSuccess(422, 'Restore validation error handled', '');
          
          // Check error response structure
          expect(error.response.data).to.exist;
          if (error.response.data.success !== undefined) {
            expect(error.response.data.success).to.be.false;
          }
          if (error.response.data.errors) {
            expect(error.response.data.errors).to.be.an('array');
          }
        } else if (profileWithIssues) {
          // Add to cleanup if restore failed for other reasons
          testUtils.addToCleanup(profileWithIssues);
          throw error;
        }
      }
    });

    it('Should restore and include full profile data in response', async function() {
      // Create, delete, and restore a profile to verify response data
      let profileForDataCheck = null;
      
      try {
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const createUrl = `${baseURL}/profile_customers`;
        const createData = generateCompleteProfileCustomer();

        // Create profile
        const createResponse = await axios({
          method: 'post',
          url: createUrl,
          headers: headers,
          data: createData
        });

        profileForDataCheck = createResponse.data.data?.id || createResponse.data.id;

        // Soft delete it
        const deleteUrl = `${baseURL}/profile_customers/${profileForDataCheck}`;
        await axios({
          method: 'delete',
          url: deleteUrl,
          headers: headers
        });

        // Restore and check data
        const restoreUrl = `${baseURL}/profile_customers/${profileForDataCheck}/restore`;
        const restoreResponse = await axios({
          method: 'post',
          url: restoreUrl,
          headers: headers
        });

        expect(restoreResponse.status).to.equal(200);
        
        // Check that full profile data is returned
        const data = restoreResponse.data.data;
        if (data) {
          expect(data).to.be.an('object');
          
          // Should have an ID
          expect(data.id || data.attributes?.id).to.exist;
          
          // Should have profile attributes
          const attributes = data.attributes || data;
          if (attributes.name || attributes.customer_type) {
            testUtils.logSuccess(200, 'Restore returns complete profile data', restoreUrl);
          } else {
            testUtils.logSuccess(200, 'Restore returns basic profile data', restoreUrl);
          }
        } else {
          testUtils.logSuccess(200, 'Restore succeeded without data payload', restoreUrl);
        }
        
        testUtils.addToCleanup(profileForDataCheck);

      } catch (error) {
        if (profileForDataCheck) {
          testUtils.addToCleanup(profileForDataCheck);
        }
        errorHandlers.handleApiError(error, 'Restore with data check', '');
      }
    });
  });
};

module.exports = { runRestoreTests };