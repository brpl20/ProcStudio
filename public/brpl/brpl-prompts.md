Auth Review: 

Review authentication methods: JWT and CSRF , check if they are following the best practices: Check class BackofficeController and general ApplicationController, tell me what you think about them 


When checking a Ruby on Rails app for the quality of user authentication, there are several key areas to focus on. Here's what you should look for:

## Security Best Practices

1. **Password storage** - Ensure passwords are properly hashed (not encrypted or stored as plaintext). Rails uses bcrypt by default with has_secure_password, which is good practice.

2. **Password requirements** - Check if the app enforces strong password policies with minimum length, complexity requirements, and rejection of commonly used passwords.

3. **Brute force protection** - Look for account lockout mechanisms or rate limiting on login attempts to prevent brute force attacks.

4. **Session management** - Verify proper session handling with secure session cookies that have appropriate expiration, HttpOnly and Secure flags.

5. **CSRF protection** - Rails has built-in CSRF protection via authenticity tokens, but verify it's actually enabled and used consistently.

## Implementation Quality

1. **Authentication gem** - Check if the app uses a well-maintained gem like Devise, Clearance, or Authlogic rather than a custom implementation.

2. **Multi-factor authentication** - See if 2FA/MFA is implemented, particularly for admin or sensitive user accounts.

3. **Secure password reset flow** - Ensure the password reset process uses time-limited tokens sent to verified email addresses.

4. **Secure account recovery** - Look for robust account recovery methods that don't bypass security.

5. **Proper authorization** - Check that authentication is paired with proper authorization (using gems like CanCanCan, Pundit).

## Usability Considerations

1. **Login UX** - Evaluate the login experience for usability while maintaining security.

2. **Error messages** - Check that error messages don't reveal too much information (e.g., whether a username exists).

3. **Remember me functionality** - If implemented, ensure it's done securely.

Would you like me to dive deeper into any of these specific areas?

BackOffice Controler : This is just creating a mess, copy it's configurations

--- 


Create a visual styling for our system, ou colors are the following, follow Rails, CSS, Tailwind and Daisy best practices to create global variables to easily use them, set a friendly name. 


--- 

Please create a frontend, you can take inspiration from: 

/Users/brpl/code/prc_admin-fe/src/components/LandingPageSections

Also copy assets to our system. This is an old React project that we are migrating to Rails Views. 

Just don't follow the colors and fonts, we can keep or own styling. 

---


Also Remove the top sidebar and create an lateral sidebar, you can copy the elements in /frontend

/Users/brpl/code/prc_api/frontend/src/lib/components/AuthSidebar.svelte

Also copy /Users/brpl/code/prc_api/frontend/src/lib/icons.svelte icons from there 

--- 

