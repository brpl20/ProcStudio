# Prompts

Review: as QA and code specialist check the last commit and inspect code quality and check if there is any improvements to be done to the code be more consise, follow dry rules and software development best practices;

Following dry rules and software development best practices, please go throught src/lib/components/teams/OfficeForm.svelte, /Users/brpl/code/prc_api/frontend/src/lib/components/customers/CustomerFormStep1.svelte and inspect: E-mail. Them create a /forms_commons e-mail component that will be able to be used across all the system. Use current validators at /validation

gaa gcam gp { follow Conventional Commits rules }

Following dry rules and software development best practices, please go throught src/lib/components/teams/OfficeForm.svelte, /Users/brpl/code/prc_api/frontend/src/lib/components/customers/CustomerFormStep1.svelte and inspect: E-mail. Them create a /forms_commons e-mail component that will be able to be used across all the system. Use current validators at /validation

1. Type Safety Improvements

// Replace 'any' with proper types
interface ApiError {
message: string;
code: number;
}

// Instead of: catch (error: any)
catch (error: unknown) {
const apiError = error as ApiError;
}

    2. DRY Principle Violations

- Error handling patterns repeated across services
- Validation logic duplicated
- Console logging scattered throughout

3. Best Practice Violations

- No centralized error handling
- Inconsistent async/await patterns
- Missing error boundaries
- Hardcoded strings instead of constants
