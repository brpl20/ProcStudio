# Frontend - Forms - Stores - Schemas -

O funcionamento básico do sistema de formulários será mais ou menos o seguinte:

- Componentes individuais -> Wrappers -> { Pages } Stores -> Schemas

# Componentes Individuais - Atomic Components

Primeiro criamos componentes individuais. Se eles puderem ser usados em +1 lugar (geralmente genéricos como CPF), devem ser inseridos como componentes comuns `/components/forms_commons`;

Se eles forem utilizados em apenas um lugar, devem ser inseridos como componentes específicos com seu próprio nome, por exemplo: `components/forms_offices`;

Depois nós vamos agrupar isso de acordo com o uso, seguindo a mesma regra. Se eles puderem ser usados em +1 lugar (geralmente genéricos como endereço), devem ser inseridos como componentes comuns `components/forms_commons_wrappers/BasicInformation.svelte`;

Se eles forem utilizados em apenas um lugar, devem ser inseridos como componentes específicos com seu próprio nome, por exemplo: `components/forms_offices_wrappers`;

# Como deixar os wrappers comuns dinâmicos

Mesmo sabendo que os wrappers são componentes genéricos algumas coisas precisam ser mais específicas de acordo com cada local. Você não vai querer que o sistema fique engessado. Então uma sociedade/empresa por exemplo quando é tratada como um `customer` é diferente de quando ela é tratada como um `office` que faz parte de um sistema interno do sistema.

Por exemplo em `components/forms_commons/SocietyName.svelte` nós temos este componente genérico para empresas:

```js
labelText = 'Nome da Sociedade',
placeholder = 'Nome da sociedade',
```

Que no entanto, é utilizado no Office como:
```js
labelText="Nome do Escritório"
placeholder="Nome do escritório"
```

Assim, devemos deixar para customizar criar componentes pai/filhos, isso evita excesso de código nas próprias páginas, o que torna mais difícil configurações granulares. No exemplo abaixo estamos utilizando, o `components/forms_commons_wrappers/OfficeBasicInformation.svelte` como elemento pai do elemento filho `components/forms_commons_wrappers/SocietyBasicInformation.svelte`.

## Exemplo de Como Implementar

### Estrutura de Herança Pai/Filho

A implementação do padrão de herança segue esta estrutura hierárquica:

```
SocietyBasicInformation.svelte (PAI - Base genérica)
├── OfficeBasicInformation.svelte (FILHO - Específico para offices)
├── CustomerBasicInformation.svelte (FILHO - Específico para customers) 
└── LawyerBasicInformation.svelte (FILHO - Específico para lawyers)
```

#### 1. Componente Pai (SocietyBasicInformation.svelte)

O componente pai é completamente genérico e aceita configuração via `fieldsConfig`:

```typescript
interface FieldConfig {
  id: string;
  labelText: string;
  required?: boolean;
  show?: boolean;
}
```

Características do Pai:
- Base genérica para todas as sociedades
- Sistema de configuração flexível via `fieldsConfig`
- Controle de visibilidade de campos
- Validação dinâmica com prevenção de loops infinitos
- Interfaces genéricas reutilizáveis

#### 2. Componente Filho (OfficeBasicInformation.svelte)

O componente filho herda toda funcionalidade do pai e apenas especializa a configuração:

```typescript
const officeFieldsConfig = {
  name: {
    id: 'office-name',
    labelText: 'Nome do Escritório',
    required: true
  }
};
```

Características do Filho:
- Especializado para offices
- Configuração office-specific (IDs, labels, placeholders)
- Herda toda lógica do pai sem duplicação de código
- Types específicos para o contexto office
- Props amigáveis para facilitar uso nas páginas

#### 3. Uso na Página

```svelte
<OfficeBasicInformation
  bind:formData={newOfficeStore.formData}
  cnpjRequired={false}
  foundationRequired={true}
/>
```

#### 4. Vantagens do Padrão

- DRY Máximo: Toda lógica complexa no pai, zero duplicação
- Especialização: Cada filho tem sua personalidade específica
- Escalabilidade: Fácil criar novos tipos (Customer, Lawyer, etc.)
- Type Safety: Interfaces específicas para cada contexto
- Low Complexity: Filhos são apenas configurações simples
- Flexibilidade: Sistema de configuração poderoso no pai

#### 5. Adicionando Novos Tipos

Para criar um novo tipo (ex: Customer), basta:

```typescript
const customerFieldsConfig = {
  name: {
    id: 'customer-name',
    labelText: 'Nome do Cliente',
    required: true
  }
};
```

# Stores

## src/lib/stores/newOfficeStore.svelte.ts

O store é responsável por gerenciar o estado do formulário e integrar com a validação dinâmica:

### Estrutura Básica

```typescript
class NewOfficeStore {
  private state = $state({
    formData: createDefaultNewOfficeFormData(),
    validationConfig: createDefaultValidationConfig()
  });

  isValid = $derived(
    validateNewOfficeForm(this.state.formData, this.state.validationConfig).length === 0
  );
}
```

### Funcionalidades Principais

#### 1. Gerenciamento de Estado

```typescript
updateField<K extends keyof NewOfficeFormData>(field: K, value: NewOfficeFormData[K]) {
  this.state.formData[field] = value;
}
```

#### 2. Validação Dinâmica

```typescript
setValidationConfig(config: FormValidationConfig) {
  this.state.validationConfig = config;
}
```

#### 3. Operações de API

```typescript
async saveNewOffice(): Promise<Office | null> {
  if (!this.canSubmit) return null;
  // ... lógica de salvamento
}
```

### Padrões do Store

#### Estado Reativo com Svelte 5
- Uso de `$state()` para estado interno
- Uso de `$derived()` para estados computados
- Getters para acesso controlado ao estado

#### Integração com Validação
- `validationConfig` armazena regras dinâmicas
- `isValid` recalcula automaticamente quando dados ou config mudam
- `canSubmit` combina multiple condições

#### Feedback de UI
- Estados de `loading`, `saving`, `error`, `success`
- `isDirty` para detectar mudanças
- Mensagens claras para o usuário

# Schemas

## src/lib/schemas/new-office-form.ts

O schema define a estrutura dos dados, validação e transformações:

### Interfaces Principais

#### 1. Dados do Formulário

```typescript
export interface NewOfficeFormData {
  name: string;
  cnpj: string;
  society: string;
  // ... outros campos
}
```

#### 2. Configuração de Validação Dinâmica

```typescript
export interface FieldValidationRule {
  required?: boolean;
  customValidator?: (value: any) => string | null;
}

export interface FormValidationConfig {
  [fieldName: string]: FieldValidationRule;
}
```

### Funções Principais

#### 1. Criação e Configuração

```typescript
export function createDefaultValidationConfig(): FormValidationConfig {
  return {
    name: { required: true },
    cnpj: { required: false, customValidator: validateCNPJOptional }
  };
}
```

#### 2. Validação Dinâmica

```typescript
export function validateNewOfficeForm(
  formData: NewOfficeFormData, 
  validationConfig: FormValidationConfig = createDefaultValidationConfig()
): string[] {
  // ... lógica de validação dinâmica
}
```

#### 3. Transformação de Dados

```typescript
export function transformNewOfficeFormToApiRequest(
  formData: NewOfficeFormData
): Partial<CreateOfficeRequest> {
  // ... transformações para API
}
```

### Padrões do Schema

#### Flexibilidade
- Validação configurável via `FormValidationConfig`
- Suporte a validadores customizados
- Transformações específicas para cada contexto

#### Type Safety
- Interfaces bem definidas
- Funções tipadas para transformações
- Validação de tipos em tempo de compilação

#### Reutilização
- Funções puras e testáveis
- Configuração separada da lógica
- Padrão aplicável a outros formulários

### Integração Completa

O fluxo completo funciona assim:

```
OfficeBasicInformation → Props: cnpjRequired=true → SocietyBasicInformation → 
Gera: FormValidationConfig → Store: setValidationConfig → 
Schema: validateNewOfficeForm → UI: isValid, canSubmit
```

Esta arquitetura garante que mudanças simples nas props dos wrappers se propagam automaticamente através de todo o sistema de validação, mantendo a interface de usuário sempre sincronizada com as regras de negócio.
