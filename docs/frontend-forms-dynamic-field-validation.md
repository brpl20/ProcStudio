[back](../README.md)

# Frontend - Dynamic Field Validation

- O uso de campos dinâmicos na validação dos formulários permite que nós possamos rapidamente mudar as formas de validação nas páginas, passando props para elas e alterando o comportamento da validação sem precisar alterar os códigos das Stores e dos Schemas:

Neste exemplo abaixo usando a criação de um escritório poemos ver que essas linhas abaixo devem ser adicionadas now wrappers para permitir a passagem de props para os campos dinâmicos, bem como a passagem na própria página, como neste caso `OfficeCreationPage.svelte`:

```bash
⏺ Update(src/lib/components/forms_commons_wrappers/BasicInformation.svelte)
  ⎿  Updated src/lib/components/forms_commons_wrappers/BasicInformation.svelte with 1 addition
       25        cnpjRequired?: boolean;
       26        cnpjDisabled?: boolean;
       27        cnpjValidate?: boolean;
       28 +      foundationRequired?: boolean;
       29        onValidationConfigChange?: (config: FormValidationConfig) => void;
       30      };
       31

⏺ Update(src/lib/components/forms_commons_wrappers/BasicInformation.svelte)
  ⎿  Updated src/lib/components/forms_commons_wrappers/BasicInformation.svelte with 1 addition
       43        cnpjRequired = false,
       44        cnpjDisabled = false,
       45        cnpjValidate = true,
       46 +      foundationRequired = false,
       47        onValidationConfigChange
       48      }: Props = $props();
       49

⏺ Update(src/lib/components/forms_commons_wrappers/BasicInformation.svelte)
  ⎿  Updated src/lib/components/forms_commons_wrappers/BasicInformation.svelte with 1 addition and 1 removal
       61            },
       62            society: { required: false },
       63            accounting_type: { required: false },
       64 -          foundation: { required: false },
       64 +          foundation: { required: foundationRequired },
       65            site: { required: false }
       66          };
       67

⏺ Update(src/lib/pages/Office/OfficeCreationPage.svelte)
  ⎿  Updated src/lib/pages/Office/OfficeCreationPage.svelte with 1 addition
       54        <BasicInformation
       55          bind:formData={newOfficeStore.formData}
       56          cnpjRequired={false}
       57 +        foundationRequired={true}
       58          onValidationConfigChange={handleValidationConfigChange}
       59        />
       60
```

## Explicação Técnica

O sistema de validação dinâmica implementado segue um padrão híbrido que combina configuração flexível com detecção automática de props. A arquitetura foi dividida em 4 camadas principais:

### 1. Interfaces e Tipos (`new-office-form.ts`)

```typescript
// Interface para configuração de validação de campo
interface FieldValidationRule {
  required?: boolean;
  customValidator?: (value: any) => string | null;
}

// Configuração dinâmica para todo o formulário
interface FormValidationConfig {
  [fieldName: string]: FieldValidationRule;
}
```

**Objetivo**: Criar uma estrutura flexível que permita configurar validação para qualquer campo do formulário sem modificar o código core.

### 2. Schema Dinâmico (`validateNewOfficeForm`)

```typescript
export function validateNewOfficeForm(
  formData: NewOfficeFormData, 
  validationConfig: FormValidationConfig = createDefaultValidationConfig()
): string[] {
  const errors: string[] = [];

  // Itera através de todos os campos na configuração
  for (const [fieldName, rules] of Object.entries(validationConfig)) {
    const fieldValue = formData[fieldName as keyof NewOfficeFormData];

    // Verifica validação required
    if (rules.required && (!fieldValue || !String(fieldValue).trim())) {
      const fieldLabel = getFieldLabel(fieldName);
      errors.push(`${fieldLabel} é obrigatório`);
      continue;
    }

    // Aplica validador customizado se fornecido
    if (rules.customValidator && fieldValue) {
      const customError = rules.customValidator(fieldValue);
      if (customError) {
        errors.push(customError);
      }
    }
  }

  return errors;
}
```

**Benefícios**:
- ✅ **Genérico**: Funciona para qualquer campo
- ✅ **Extensível**: Suporta validadores customizados
- ✅ **Retrocompatível**: Configuração padrão mantém comportamento original

### 3. Wrapper Inteligente (`BasicInformation.svelte`)

```typescript
// Auto-geração de configuração baseada nas props
$effect(() => {
  if (onValidationConfigChange) {
    const validationConfig: FormValidationConfig = {
      name: { required: true },
      cnpj: { 
        required: cnpjRequired,
        customValidator: cnpjValidate ? validateCNPJOptional : undefined
      },
      foundation: { required: foundationRequired },
      // ... outros campos
    };

    // Previne loops infinitos comparando configurações
    const configString = JSON.stringify(validationConfig);
    if (configString !== previousConfig) {
      previousConfig = configString;
      onValidationConfigChange(validationConfig);
    }
  }
});
```

**Características**:
- 🔄 **Auto-detecção**: Detecta automaticamente props `*Required`
- 🛡️ **Prevenção de loops**: Evita re-renderizações infinitas
- 🎛️ **Configuração automática**: Gera config sem intervenção manual

### 4. Store Reativo (`newOfficeStore.svelte.ts`)

```typescript
class NewOfficeStore {
  private state = $state({
    formData: createDefaultNewOfficeFormData(),
    validationConfig: createDefaultValidationConfig() // ← Nova configuração
  });

  // Validação dinâmica usando a configuração atual
  isValid = $derived(
    validateNewOfficeForm(this.state.formData, this.state.validationConfig).length === 0
  );

  // Método para atualizar configuração
  setValidationConfig(config: FormValidationConfig) {
    this.state.validationConfig = config;
  }
}
```

### 5. Fluxo de Dados Completo

```mermaid
flowchart TD
    A[Página: foundationRequired=true] --> B[Wrapper: detecta props]
    B --> C[Wrapper: gera validationConfig]
    C --> D[Store: setValidationConfig()]
    D --> E[Store: isValid $derived]
    E --> F[Schema: validateNewOfficeForm()]
    F --> G[UI: botão disabled/enabled]
```

### 6. Vantagens da Implementação

#### **Escalabilidade**
- Adicionar novo campo required: `oabRequired={true}`
- Sem modificação de código interno
- Padrão replicável para outros formulários

#### **Manutenibilidade**
- Lógica de validação centralizada
- Separação clara de responsabilidades
- Type-safety completo

#### **Performance**
- Prevenção de loops infinitos
- Validação reativa eficiente
- Configuração calculada apenas quando necessário

#### **Flexibilidade**
- Suporte a validadores customizados
- Configuração dinâmica em runtime
- Retrocompatibilidade total

### 7. Padrão de Nomenclatura

Para manter consistência, siga o padrão:
- **Props**: `{campo}Required`, `{campo}Disabled`, `{campo}Validate`
- **Config**: Usar nome exato do campo no formData
- **Labels**: Centralizados na função `getFieldLabel()`

Este sistema permite transformar qualquer campo em required/optional sem tocar no código de validação, mantendo a flexibilidade e escalabilidade do sistema.
