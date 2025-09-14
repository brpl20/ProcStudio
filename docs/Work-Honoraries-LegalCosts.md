[Back](../README.md)

Esse endpoint é para permitir que o User tenha liberdade para criar suas próprias entradas de LegalCosts (Custas Processuais) uma vez que existe uma gama muito grande desse tipo de despesas que é impossível de prever.
How the LegalCostType Key Works:
System Types (Pre-defined)

System types have pre-defined keys like custas_judiciais, taxa_judiciaria, etc.
These are created via seeds with is_system: true and team_id: nil
System types are shared across all teams
Their keys cannot be edited by users

Custom Types (Team-specific)

Teams can create their own custom cost types
When creating a custom type, the user must provide a key
The key must be unique within that team's scope
This means Team A can have custom_fee and Team B can also have custom_fee without conflict

Frontend Implementation
 Based on the controller params, the frontend should:
 // When creating a new custom legal cost type
 POST /api/v1/legal_cost_types
 {
 "legal_cost_type": {
 "key": "taxa_especial", // User needs to provide this
 "name": "Taxa Especial do Cliente",
 "description": "Taxa específica para este cliente",
 "category": "other",
 "display_order": 500,
 "active": true
 }
 }
Key Generation Strategy (Recommended for Frontend)
 The frontend could implement a key generation helper:
 // Convert name to a valid key
 function generateKey(name) {
 return name
 .toLowerCase()
 .normalize('NFD')
 .replace(/[\u0300-\u036f]/g, '') // Remove accents
 .replace(/[^a-z0-9]+/g, '') // Replace non-alphanumeric with underscore__.replace(/^|_$/g, ''); // Remove leading/trailing underscores
 }
 // Example:
 // "Taxa Especial do Cliente" -> "taxa_especial_do_cliente"
 // "Honorários Periciais 2024" -> "honorarios_periciais_2024"
UI/UX Recommendations
 For the best user experience, the frontend should:
Auto-generate the key from the name field as the user types
Allow manual editing of the auto-generated key if needed
Validate uniqueness before submission (optional API endpoint could be added)
Show existing keys to avoid duplicates
Indicate system vs custom types clearly in the UI
When Selecting Cost Types
 When creating a LegalCostEntry, users select from:

System types (available to all teams)
Their team's custom types
  The selection would typically be a dropdown showing the name field, but storing the legal_cost_type_id in the
  database.
  Would you like me to create an endpoint to validate key uniqueness or add a key generation helper to the API?
