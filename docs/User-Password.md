[Back](../README.md)

# User Password Components Documentation

## Overview

ProcStudio Frontend provides a comprehensive password input system with three specialized components for different use cases, along with configurable validation rules and instant feedback. These components are built with Svelte 5 runes, follow accessibility best practices, and integrate seamlessly with DaisyUI styling.

## Architecture

### Components

The password system consists of three main components located in `frontend/src/lib/components/forms_commons/`:

1. **Password.svelte** - Basic password input with simple validation (for login)
2. **PasswordWithValidation.svelte** - Advanced password input with configurable requirements and visual feedback
3. **PasswordConfirmation.svelte** - Password confirmation with matching validation

### Validation System

The validation logic is centralized in two modules:

- **`frontend/src/lib/validation/password.ts`** - Legacy validation rules and validators (basic)
- **`frontend/src/lib/validation/password-config.ts`** - Advanced configurable validation system (production recommended)

-> Não estamos usando o sistema de validação por enquanto (dev-mode) isso só será utilizado em produção senão atrasa muito o desenvolvimento.
