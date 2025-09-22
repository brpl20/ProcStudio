# Frontend Forms and Decoupling Architecture

This document outlines the new decoupled approach for building forms and UI components in the ProcStudio frontend, promoting reusability, maintainability, and consistency.

## Overview

The frontend has been restructured to use a **decoupled component architecture** where complex forms are broken down into:

1. **Individual Field Components** - Atomic, reusable form fields
2. **Wrapper Components** - Logical groupings of related fields
3. **Page-Level Components** - Complete forms that compose wrappers and fields

### Why?
Because this will enable to create easier police concerns in the frontend, instead of wraping big chunks of code inside an `if` statement, we will have small and granular components to deal with.

## Architecture

```
src/lib/components/
├── forms_commons/                    # Fields that can be used in multiple fields;
├── forms_commons_wrappers/           # Wrappers for general fields;
├── forms_{domain_specific}/          # Fields that are domain specific;
├── forms_{domain_specific}_wrappers/ # Wrappers for domain specific;
```

- forms_commons fields:
  - Address and Cep
  - Bank
  - CNPJ
  - CPF
  - Email
  - Phone
  - Name?
  - FullName?
  - Name (company)?
  - Capacity?
  - Birth?

- form_domain_specific => forms_offices + forms_offices_wrappers
