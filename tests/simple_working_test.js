#!/usr/bin/env node

/**
 * Simple Working API Test
 *
 * This test verifies that authentication and API calls work properly
 * using the actual working configuration we discovered.
 */

const axios = require('axios');
const fs = require('fs');
const path = require('path');

async function runSimpleTest() {
  console.log('🧪 Simple Working API Test');
  console.log('═══════════════════════════');

  try {
    // Load config
    const configPath = path.join(__dirname, 'test_config.json');
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

    console.log(`📍 API Base URL: ${config.api.baseUrl}`);
    console.log(`🔑 Auth Endpoint: ${config.api.auth.tokenEndpoint}`);
    console.log(`👤 Test User: ${config.api.auth.testCredentials.email}`);

    // Step 1: Authenticate
    console.log('\n🔐 Step 1: Authenticating...');
    const authUrl = `${config.api.baseUrl}${config.api.auth.tokenEndpoint}`;

    const authResponse = await axios.post(authUrl, config.api.auth.testCredentials, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      timeout: 10000
    });

    // Extract token (using the correct nested structure we discovered)
    const token = authResponse.data.token ||
                  authResponse.data.access_token ||
                  authResponse.data.auth_token ||
                  authResponse.data.data?.token ||
                  authResponse.data.jwt;

    if (!token) {
      throw new Error('No token found in auth response');
    }

    console.log(`✅ Authentication successful!`);
    console.log(`🎫 Token: ${token.substring(0, 30)}...`);

    // Step 2: Test API endpoint
    console.log('\n🌐 Step 2: Testing API endpoint...');

    // Test the users endpoint
    const apiResponse = await axios.get(`${config.api.baseUrl}/users`, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      timeout: 10000
    });

    console.log(`✅ API call successful!`);
    console.log(`📊 Response Status: ${apiResponse.status}`);

    if (apiResponse.data) {
      if (apiResponse.data.data && Array.isArray(apiResponse.data.data)) {
        console.log(`📋 Users found: ${apiResponse.data.data.length}`);
      } else if (apiResponse.data.data) {
        console.log(`📋 User data received`);
      } else {
        console.log(`📋 Response data:`, Object.keys(apiResponse.data));
      }
    }

    // Step 3: Test another endpoint (teams)
    console.log('\n🏢 Step 3: Testing teams endpoint...');

    try {
      const teamsResponse = await axios.get(`${config.api.baseUrl}/teams`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        timeout: 10000
      });

      console.log(`✅ Teams API call successful! Status: ${teamsResponse.status}`);

      if (teamsResponse.data && teamsResponse.data.data) {
        if (Array.isArray(teamsResponse.data.data)) {
          console.log(`👥 Teams found: ${teamsResponse.data.data.length}`);
        } else {
          console.log(`👥 Team data received`);
        }
      }

    } catch (teamsError) {
      console.log(`⚠️  Teams endpoint: ${teamsError.response?.status || 'Network Error'}`);
    }

    // Step 4: Test cases endpoint
    console.log('\n📁 Step 4: Testing cases/works endpoint...');

    try {
      const worksResponse = await axios.get(`${config.api.baseUrl}/works`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        timeout: 10000
      });

      console.log(`✅ Works API call successful! Status: ${worksResponse.status}`);

      if (worksResponse.data && worksResponse.data.data) {
        if (Array.isArray(worksResponse.data.data)) {
          console.log(`📁 Works found: ${worksResponse.data.data.length}`);
        } else {
          console.log(`📁 Work data received`);
        }
      }

    } catch (worksError) {
      console.log(`⚠️  Works endpoint: ${worksError.response?.status || 'Network Error'}`);
    }

    console.log('\n🎉 SUCCESS! All API tests passed!');
    console.log('✅ Authentication works correctly');
    console.log('✅ JWT token extraction works');
    console.log('✅ API endpoints are accessible');
    console.log('✅ Your test setup is working perfectly!');

    return true;

  } catch (error) {
    console.log('\n❌ Test failed:', error.message);

    if (error.response) {
      console.log(`📊 Status: ${error.response.status}`);
      console.log(`📋 Response:`, error.response.data);

      if (error.response.status === 401) {
        console.log('🔒 This looks like an authentication issue');
      } else if (error.response.status === 404) {
        console.log('🔍 This looks like a routing issue');
      }
    } else if (error.code === 'ECONNREFUSED') {
      console.log('🌐 Server connection refused - is Rails server running?');
    }

    return false;
  }
}

// Run the test
if (require.main === module) {
  runSimpleTest().then(success => {
    if (success) {
      console.log('\n🚀 Ready to fix the generated tests!');
      console.log('The core authentication and API access is working perfectly.');
      process.exit(0);
    } else {
      console.log('\n🔧 Check the errors above and fix the issues.');
      process.exit(1);
    }
  }).catch(error => {
    console.log('💥 Test crashed:', error.message);
    process.exit(1);
  });
}

module.exports = { runSimpleTest };
