export const apiTesting = {
  api: {
    baseUrl: "http://localhost:3000/api/v1",
    timeout: 1000,
    retries: 3,
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
    },
    auth: {
      type: "bearer",
      tokenEndpoint: "/login",
      tokenStorage: true,
      autoRefresh: true,
      refreshThreshold: 300000,
      testCredentials: {
        email: "u1@gmail.com",
        password: "123456",
      },
    },
  },
};

// // Test Users para o futuro: Secretária, Paralegal etc
// testUsers: {
//   admin: {
//     email: "admin@e2etest.procstudio.com",
//     password: "E2ETestPass123!"
//   },
//   user: {
//     email: "user@e2etest.procstudio.com",
//     password: "E2ETestPass123!"
//   },
//   lawyer: {
//     email: "lawyer@e2etest.procstudio.com",
//     password: "E2ETestPass123!"
//   }
// }
