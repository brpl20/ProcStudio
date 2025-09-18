# Frontend Forms and Decoupling Architecture

This document outlines the new decoupled approach for building forms and UI components in the ProcStudio frontend, promoting reusability, maintainability, and consistency.

## Overview

The frontend has been restructured to use a **decoupled component architecture** where complex forms are broken down into:

1. **Individual Field Components** - Atomic, reusable form fields
2. **Wrapper Components** - Logical groupings of related fields
3. **Page-Level Components** - Complete forms that compose wrappers and fields

## Architecture

```
src/lib/components/
├── forms_commons/                    # Atomic field components
├── forms_commons_wrappers/           # Logical groupings
```
