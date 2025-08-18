# Frontend - PRC API

Sistema frontend desenvolvido com Svelte, TypeScript e Vite.

## 🚀 Início Rápido

```bash
# Instalar dependências
npm install

# Iniciar servidor de desenvolvimento
npm run dev

# Build para produção
npm run build

# Preview da build de produção
npm run preview
```

## 📋 Padrões de Código e Boas Práticas

### Configuração de Qualidade de Código

Este projeto utiliza ESLint, Prettier e Husky para garantir qualidade e consistência do código.

#### Scripts Disponíveis

```bash
npm run lint        # Verifica erros de lint
npm run lint:fix    # Corrige erros automaticamente
npm run format      # Formata código com Prettier
npm run check       # Executa lint + verificação de formatação
```

### Regras de Estilo de Código

#### 1. **Formatação Geral**
- **Indentação**: 2 espaços (não usar tabs)
- **Aspas**: Sempre usar aspas simples (`'`) exceto quando necessário escapar
- **Ponto e vírgula**: Sempre incluir no final das declarações
- **Vírgulas finais**: Não usar vírgulas no último item de arrays/objetos
- **Espaçamento em objetos**: Sempre incluir espaços (`{ foo: 'bar' }`)
- **Parênteses em arrow functions**: Sempre usar (`(x) => x * 2`)
- **Largura máxima de linha**: 100 caracteres

#### 2. **TypeScript**
- **Tipos explícitos**: Preferir tipos específicos ao invés de `any`
- **Interfaces**: Usar para definir estruturas de dados
- **Type assertions**: Evitar `!` (non-null assertion) quando possível
- **Variáveis não utilizadas**: Prefixar com `_` se necessário manter

#### 3. **Svelte**
- **Componentes**: Nome em PascalCase (ex: `UserProfile.svelte`)
- **Props**: Usar TypeScript para tipar props quando possível
- **Eventos**: Seguir padrão de nomenclatura do Svelte
- **Acessibilidade**: Garantir labels em formulários e atributos ARIA apropriados

#### 4. **Variáveis e Funções**
- **const vs let**: Sempre usar `const` para valores que não mudam
- **var**: Nunca usar `var`, sempre `const` ou `let`
- **Comparações**: Usar `===` e `!==` (comparação estrita)
- **Chaves em condicionais**: Sempre usar chaves, mesmo para uma linha

### Exemplos de Código

#### ✅ Correto
```typescript
// Importações organizadas
import { writable } from 'svelte/store';
import type { User } from './types';

// Constantes em UPPER_CASE
const MAX_RETRIES = 3;

// Interfaces bem definidas
interface ApiResponse {
  success: boolean;
  data?: User;
  error?: string;
}

// Funções com tipos explícitos
const fetchUser = async (id: string): Promise<User> => {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) {
    throw new Error('Failed to fetch user');
  }
  return response.json();
};

// Uso correto de const/let
const userName = 'João';
let isLoading = false;

// Comparação estrita
if (userName === 'João') {
  console.log('Olá João!');
}
```

#### ❌ Evitar
```javascript
// Sem tipos
function fetchUser(id) {
  return fetch("/api/users/" + id)
}

// Uso de var
var userName = "João"

// Comparação não estrita
if (userName == "João")
  console.log("Olá João!")  // Sem chaves

// Vírgulas finais desnecessárias
const config = {
  api: "http://localhost",
  timeout: 5000,  // ❌ vírgula final
}
```

### Estrutura de Pastas

```
src/
├── lib/           # Componentes e utilidades reutilizáveis
│   ├── api.ts     # Funções de API
│   ├── stores.ts  # Stores do Svelte
│   └── *.svelte   # Componentes
├── assets/        # Imagens, fontes, etc.
├── App.svelte     # Componente principal
└── main.js        # Ponto de entrada
```

### Git Hooks

O projeto utiliza Husky para executar verificações antes dos commits:

1. **Pre-commit**: Executa automaticamente:
   - ESLint com auto-fix em arquivos `.js`, `.ts`, `.svelte`
   - Prettier para formatação
   - Bloqueia o commit se houver erros não corrigíveis

### Boas Práticas Gerais

1. **Componentização**: Dividir em componentes pequenos e reutilizáveis
2. **Estado**: Usar stores do Svelte para estado compartilhado
3. **Tipos**: Sempre tipar dados de API e props de componentes
4. **Erros**: Tratar erros adequadamente com try/catch
5. **Console**: Remover `console.log` antes de commitar (o lint avisa)
6. **Comentários**: Escrever código autoexplicativo, comentários apenas quando necessário
7. **Nomes**: Usar nomes descritivos para variáveis e funções
8. **DRY**: Não repetir código, extrair para funções/componentes reutilizáveis

### Desenvolvimento

#### Requisitos
- Node.js 18+
- npm ou yarn

#### Configuração do VS Code

Extensões recomendadas (já configuradas em `.vscode/extensions.json`):
- Svelte for VS Code
- ESLint
- Prettier

## Recommended IDE Setup

[VS Code](https://code.visualstudio.com/) + [Svelte](https://marketplace.visualstudio.com/items?itemName=svelte.svelte-vscode).

## Need an official Svelte framework?

Check out [SvelteKit](https://github.com/sveltejs/kit#readme), which is also powered by Vite. Deploy anywhere with its serverless-first approach and adapt to various platforms, with out of the box support for TypeScript, SCSS, and Less, and easily-added support for mdsvex, GraphQL, PostCSS, Tailwind CSS, and more.

## Technical considerations

**Why use this over SvelteKit?**

- It brings its own routing solution which might not be preferable for some users.
- It is first and foremost a framework that just happens to use Vite under the hood, not a Vite app.

This template contains as little as possible to get started with Vite + Svelte, while taking into account the developer experience with regards to HMR and intellisense. It demonstrates capabilities on par with the other `create-vite` templates and is a good starting point for beginners dipping their toes into a Vite + Svelte project.

Should you later need the extended capabilities and extensibility provided by SvelteKit, the template has been structured similarly to SvelteKit so that it is easy to migrate.

**Why `global.d.ts` instead of `compilerOptions.types` inside `jsconfig.json` or `tsconfig.json`?**

Setting `compilerOptions.types` shuts out all other types not explicitly listed in the configuration. Using triple-slash references keeps the default TypeScript setting of accepting type information from the entire workspace, while also adding `svelte` and `vite/client` type information.

**Why include `.vscode/extensions.json`?**

Other templates indirectly recommend extensions via the README, but this file allows VS Code to prompt the user to install the recommended extension upon opening the project.

**Why enable `checkJs` in the JS template?**

It is likely that most cases of changing variable types in runtime are likely to be accidental, rather than deliberate. This provides advanced typechecking out of the box. Should you like to take advantage of the dynamically-typed nature of JavaScript, it is trivial to change the configuration.

**Why is HMR not preserving my local component state?**

HMR state preservation comes with a number of gotchas! It has been disabled by default in both `svelte-hmr` and `@sveltejs/vite-plugin-svelte` due to its often surprising behavior. You can read the details [here](https://github.com/sveltejs/svelte-hmr/tree/master/packages/svelte-hmr#preservation-of-local-state).

If you have state that's important to retain within a component, consider creating an external store which would not be replaced by HMR.

```js
// store.js
// An extremely simple external store
import { writable } from 'svelte/store';
export default writable(0);
```
